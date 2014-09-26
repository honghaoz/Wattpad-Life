//
//  People.swift
//  Wattpad Life
//
//  Created by Honghao Zhang on 2014-09-26.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

import Foundation

class Person {
    var avatarURL: NSURL!
    var name: String!
    var title: String!
    
    init(name: String, title: String, avatarURLString: String) {
        self.name = name
        self.title = title
        self.avatarURL = NSURL(string: avatarURLString)
    }
    
    class func newWithDictionary(object: Dictionary<String, String>!) -> Person {
        let nameString: String! = object["name"] as String!
        let titleString: String! = object["title"] as String!
        let avatarURLString: String! = object["avatarURL"] as String!
        return Person(name: nameString, title: titleString, avatarURLString: avatarURLString)
    }
    
    class func newWithPFObject(object: PFObject!) -> Person {
        let nameString: String! = object["name"] as String!
        let titleString: String! = object["title"] as String!
        let avatarURLString: String! = object["avatarURL"] as String!
        return Person(name: nameString, title: titleString, avatarURLString: avatarURLString)
    }
}

private let _sharedPeople = People()

class People {
    var people: [Person]!
    
    init() {
        println("People inited")
    }
    
    class var sharedPeople: People {
        return _sharedPeople
    }
    
    func getPeople(success:(() -> ())?, failure:((errorMessage: String, error: NSError?) -> ())?) {
        people = [Person]()
        var query = PFQuery(className: "Person")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                println("No error: count: \(objects.count)")
                for eachObject in objects {
                    var newPerson: Person = Person.newWithPFObject(eachObject as PFObject)
                    self.people.append(newPerson)
                    print("Name: \(newPerson.name) Title: \(newPerson.title) Avatar: \(newPerson.avatarURL)\n")
                }
                println("Count: \(self.people.count)")
                success?()
            } else {
                println("Get people error")
                failure?(errorMessage: "Get people error", error: error)
            }
        }
    }
}