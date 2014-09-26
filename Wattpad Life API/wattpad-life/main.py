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

class UpdateHandler(BasicHandler):
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

app = webapp2.WSGIApplication([
    ('/', MainHandler), 
    ('/update', UpdateHandler)
], debug=True)
