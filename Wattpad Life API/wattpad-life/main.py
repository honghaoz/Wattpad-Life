#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import sys
import os
import jinja2
import json
import re
import copy
import collections
import httplib
import urllib

import logging
from google.appengine.ext import ndb
from google.appengine.api import memcache
from google.appengine.api import mail

sys.path.insert(0, 'libs')
import requests
from requests import Request, Session
from bs4 import BeautifulSoup
import xmltodict

# Global variables for jinja environment
template_dir = os.path.join(os.path.dirname(__file__), 'html_template')
jinja_env = jinja2.Environment(loader = jinja2.FileSystemLoader(template_dir), autoescape = True)

# Basic Handler
class BasicHandler(webapp2.RequestHandler):
    # rewrite the write, more neat
    def write(self, *a, **kw):
        self.response.write(*a, **kw)
    # render helper function, use jinja2 to get template
    def render_str(self, template, **params):
        t = jinja_env.get_template(template)
        return t.render(params)
    # render page using jinja2
    def render(self, template, **kw):
        self.write(self.render_str(template, **kw))

    def dumpJSON(self, dict):
        self.response.headers['Content-Type'] = 'application/json'
        self.write(json.dumps(dict))

class MainHandler(BasicHandler):
    """Handle for '/' """
    def get(self):
        self.render('home.html')

# Return tuple (true/false, content)
def getHtmlContent():
    lifeURL = "http://www.wattpad.com/life"
    session = Session()
    response = session.get(lifeURL)
    if response.status_code == requests.codes.ok:
        return True, response.content
    else:
        return False, response.content

def parseContent(htmlContent):
    # soup = BeautifulSoup(htmlContent)
    # print soup.prettify().encode('utf8')
    isSuccess, peopleList = parsePeople(htmlContent)
    if isSuccess:
        return peopleList
    else:
        return None
# Return tuple (true/false, list)
def parsePeople(htmlContent):
    peopleID = "wattpad-employees"
    peopleResultList = []
    try:
        soup = BeautifulSoup(htmlContent)
        peopleContent = soup.find(id=peopleID) # the whole for people
        peopleContentList = peopleContent.find_all("div", "profile") # list of each people's content

        for eachPerson in peopleContentList:
            newPerson = parsePerson(eachPerson)
            if newPerson:
                peopleResultList.append(newPerson)

        return True, peopleResultList
    except Exception, e:
        return False, peopleResultList
    
    # print peopleResultList
    # print len(peopleResultList)

# Return a dictionary for this person or None
def parsePerson(person):
    newPersonDict = {}
    
    avatarURL = ""
    try:
        avatarDiv = person.find("div", "avatar")
        avatarImg = avatarDiv.find("img")
        avatarURL = avatarImg["src"]
    except Exception, e:
        pass
    # print avatarURL
    newPersonDict["avatarURL"] = avatarURL

    name = ""
    try:
        nameP = person.find("p", "name")
        name = nameP.text.encode('utf-8').strip()
    except Exception, e:
        pass
    # print name
    newPersonDict["name"] = name
    
    title = ""
    try:
        # <p class="title">
        titleP = person.find("p", "title")
        title = titleP.text.encode('utf-8').strip()
    except Exception, e:
        pass
    newPersonDict["title"] = title
    # print title

    # socials = person.find("ul")

    if len(name) == 0 and len(title) == 0 and len(avatarURL) == 0:
        return None
    else:
        return newPersonDict

def getJsonDict(meta, data):
    return {"meta": meta, "data": data}

class PeopleHandle(BasicHandler):
    def get(self):
        meta = {"status": "failure", "count": 0}
        isSuccess, htmlContent = getHtmlContent()
        if isSuccess:
            people = parseContent(htmlContent)
            if people:
                meta["status"] = "success"
                meta["count"] = len(people)
                self.dumpJSON(getJsonDict(meta, people))
                return
        self.dumpJSON(getJsonDict(meta, []))

# Parse related
parseReUpdateTimes = 0
retryTime = 3
parseApplicationID = "KqnL5idvjMMBAQtqqskdymvS6vPmajthrGEFcKE6"
parseRESTApiKey = "7AsVuGnXaj93nTPmSsUhjLCGlfod3Lsz1bRqlOBP"

def createParseObject(aDict):
    try:
        print aDict
        connection = httplib.HTTPSConnection('api.parse.com', 443)
        connection.connect()
        connection.request('POST', '/1/classes/Person', json.dumps(aDict), {
               "X-Parse-Application-Id": parseApplicationID,
               "X-Parse-REST-API-Key": parseRESTApiKey,
               "Content-Type": "application/json"
             })
        result = json.loads(connection.getresponse().read())
        logging.info(result)
    except:
        logging.error("create an object failed")
        return False
    return True

def commitUpdateParse():
    global parseReUpdateTimes
    if parseReUpdateTimes > retryTime:
        logging.error("Update Parse more than 3 times")
        return False
    parseReUpdateTimes += 1
    logging.info("Re update Parse objects")

    try:
        # Clean out old data
        # 1: Collecting objectIds
        try:
            connection = httplib.HTTPSConnection('api.parse.com', 443)
            params = urllib.urlencode({"keys":"", "limit":1000})
            connection.connect()
            connection.request('GET', '/1/classes/Person?%s' % params, '', {
                   "X-Parse-Application-Id": parseApplicationID,
                   "X-Parse-REST-API-Key": parseRESTApiKey
                 })
            result = json.loads(connection.getresponse().read())
            objectIdsToBeDeleted = []
            for e in result["results"]:
                objectIdsToBeDeleted.append(e["objectId"])
        except:
            logging.error("Get objectIds failed")
            return commitUpdateParse()

        logging.info("To delete " + str(len(objectIdsToBeDeleted)) + " objects")

        # 2: Construct delete diction
        requestDictionary = {}
        requestDictionary["requests"] = []

        # restNumberToBeDeleted = len(objectIdsToBeDeleted)
        while len(objectIdsToBeDeleted) > 0:
            logging.info(len(objectIdsToBeDeleted))
            requestDictionary["requests"] = []
            # Delete 50 objects in batch
            deletedEntryNumber = 0
            for i in range(0, 50):
                try:
                    deleteRequest = {}
                    deleteRequest["method"] = "DELETE"
                    deleteRequest["path"] = "/1/classes/Person/%s" % objectIdsToBeDeleted[i]
                except:
                    deletedEntryNumber = i
                    break
                requestDictionary["requests"].append(deleteRequest)
                deletedEntryNumber = 50;

            # 3: Delete 50 entries
            connection = httplib.HTTPSConnection('api.parse.com', 443)
            connection.connect()
            connection.request('POST', '/1/batch', json.dumps(requestDictionary), {
                   "X-Parse-Application-Id": parseApplicationID,
                   "X-Parse-REST-API-Key": parseRESTApiKey,
                   "Content-Type": "application/json"
                 })
            result = json.loads(connection.getresponse().read())
            logging.info(result)
            objectIdsToBeDeleted = objectIdsToBeDeleted[deletedEntryNumber:]
    except:
        logging.error("Delete Parse Object Failed")
        return commitUpdateParse()

    logging.info("Delete Parse Object Succeed!")

    # Store new data

    sum = 0
    result = []
    try:
        isSuccess, htmlContent = getHtmlContent()
        if isSuccess:
            people = parseContent(htmlContent)
            if people:
                result = people
            else:
                return commitUpdateParse()
        else:
            return commitUpdateParse()
    except Exception, e:
        pass

    print "Old count: " + str(len(objectIdsToBeDeleted))
    print "New count: " + str(len(result))
    if result and len(result) > 0:
        for each in result:
            if not createParseObject(each):
                logging.error("Create Parse Object Failed")
                return commitUpdateParse()
            sum += 1
        logging.info("Parse updated: %d" % sum)
        return True
    else:
        logging.error("Login Failed")
        return False


class UpdateHandler(BasicHandler):
    def get(self):
        global parseReUpdateTimes
        parseReUpdateTimes = 0
        result = commitUpdateParse()
        if result:
            self.write("Parse updated successfully")
        else:
            self.write("Parse updated failed")
        

app = webapp2.WSGIApplication([
    ('/', MainHandler), 
    ('/people', PeopleHandle),
    ('/update', UpdateHandler)
], debug=True)
