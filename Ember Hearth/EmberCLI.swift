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

enum EmberTestType {
    case terminal
    case testem
    case browser
}

class EmberCLI: CLITool {
    // MARK: Class functions (tool status)
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
    
    static let name = "Ember-CLI"
    let name: String = Node.name
    
    
    // MARK: Installing Ember-CLI
    func install (completion: (success: Bool) -> ()) -> NSTask? {
        var term = Terminal()
        return term.runTerminalCommandAsync("npm install -g ember-cli", completion: { (result) -> () in
            completion(success:result != nil)
        })
    }
    
    func installIfNeeded(completion:(success:Bool) -> ()) -> NSTask? {
        if EmberCLI.isInstalled() {
            completion(success: true)
        } else {
            var ember = EmberCLI()
            return ember.install({ (success) -> () in
                completion(success: success)
            })
        }
        return nil
    }
    
    // MARK: Creating projects
    func createProject(path: String, name: String, completion: (success:Bool) -> ()) -> NSTask? {
        var term = Terminal()
        term.workingDirectory = path
        return term.runTerminalCommandAsync("ember new \"\(name)\"", completion: { (result) -> () in
            println("Attempted to create ember project: \(result)")
            completion(success: result != nil)
        })
    }
    
    
    // MARK: Running server
    func runServerTask(path:String) -> NSTask {
        var term = Terminal()
        var task = term.taskForCommand("npm install && bower install && ember serve")
        task.currentDirectoryPath = path
        return task
    }
    
    func runServer(path: String, completion:(running: Bool)->()) {
        var task = self.runServerTask(path)
        
    }
    
    
    // MARK: Building
    func build(path:String, type:EmberBuildType, completion: (result:String?) -> ()) {
        NSNotificationCenter.defaultCenter().postNotificationName("startedBuilding", object: nil)
        var term = Terminal()
        term.workingDirectory = path
        var command = "npm install && bower install && ember build"
        switch type {
        case .development:
            command += " -dev"
        case .production:
            command += " -prod"
        }
        term.runTerminalCommandAsync(command, completion: { (result) -> () in
            NSNotificationCenter.defaultCenter().postNotificationName("endedBuilding", object: result)
            completion(result: result)
        })
    }
    
    
    // MARK: Testing
    func test(path:String, type:EmberTestType) {
        let projectController = ProjectController.sharedInstance
        switch type {
        case .browser:
            if projectController.isServerRunning() {
                projectController.launchBrowserTests()
            } else {
                projectController.showTestsWhenRunning = true
                projectController.toggleServer(nil)
            }
        case .terminal:
            Terminal().runTerminalCommandInTerminalApp("ember test", path: path)
        case .testem:
            Terminal().runTerminalCommandInTerminalApp("ember test --server", path: path)
        }
    }
}
