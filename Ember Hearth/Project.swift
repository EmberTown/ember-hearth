//
//  Project.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Project {
    var name: String?
    var path: String?
    var package: NSDictionary?
    
    convenience init(dict: Dictionary<String, Any>) {
        self.init()
        name = dict["name"] as String?
        path = dict["path"] as String?
    }
    
    convenience init(name: String?, path: String?) {
        self.init()
        self.name = name
        self.path = path
    }
    
    func dictionaryRepresentation() -> Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = [:]
        if name != nil {
            dict["name"] = name!
        }
        if path != nil {
            dict["path"] = path!
        }
        return dict
    }
    
    func loadNameFromPath() -> String? {
        if path == nil {
            return nil
        }
        
        let pathToFile = path!.stringByAppendingPathComponent("package.json")
        let url = NSURL(string: pathToFile)
        if url == nil {
            return nil
        }
        let packagejson = NSData(contentsOfURL: NSURL(fileURLWithPath: pathToFile)!)
        print("Loaded package.json from \(pathToFile), found \(packagejson)")
        if packagejson != nil {
            package = NSJSONSerialization.JSONObjectWithData(packagejson!, options: nil, error: nil) as? NSDictionary
        }
        
        name = package?["name"] as? String
        return name
    }
}
