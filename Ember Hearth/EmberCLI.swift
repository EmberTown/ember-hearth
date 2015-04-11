//
//  EmberCLI.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

enum EmberBuildType {
    case development
    case production
}

class EmberCLI: CLITool {
    class func isInstalled () -> Bool {
        return version() != nil
    }
    
    class func path() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("which ember")
    }
    
    class func version () -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("ember -v")
    }
    
    func install (completion: (success: Bool) -> ()) {
        var term = Terminal()
        term.runTerminalCommandAsync("npm install -g ember-cli", completion: { (result) -> () in
            completion(success:result != nil)
        })
    }
    
    func installIfNeeded(completion:(success:Bool) -> ()) {
        if EmberCLI.isInstalled() {
            completion(success: true)
        } else {
            var ember = EmberCLI()
            ember.install({ (success) -> () in
                completion(success: success)
            })
        }
    }
    
    func createProject(path: String, name: String, completion: (success:Bool) -> ()) {
        var term = Terminal()
        term.workingDirectory = path
        term.runTerminalCommandAsync("ember new \(name)", completion: { (result) -> () in
            println("Attempted to create ember project: \(result)")
            completion(success: result != nil)
        })
    }
    
    func runServerTask(path:String) -> NSTask {
        var term = Terminal()
        var task = term.taskForCommand("ember serve")
        task.currentDirectoryPath = path
        return task
    }
    
    func build(path:String, type:EmberBuildType, completion: (result:String?) -> ()) {
        var term = Terminal()
        term.workingDirectory = path
        var command = "ember build"
        switch type {
        case .development:
            command += " -dev"
        case .production:
            command += " -prod"
        }
        term.runTerminalCommandAsync(command, completion: { (result) -> () in
            completion(result: result)
        })
    }
}
