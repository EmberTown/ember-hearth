//
//  Node.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Node: CLITool {
    class func installationMethod() -> InstallMethod {
        if Brew.isInstalled("node") {
            return InstallMethod.Brew
        } else if !Node.isInstalled() {
            return InstallMethod.NotInstalled
        }
        return InstallMethod.Unknown
    }
    
    class func isInstalled() -> Bool {
        return Node.version() != nil
    }
    
    class func path() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("which node")
    }
    
    class func version() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("node -v")
    }
    
    static let name = "Node.js"
    let name: String = Node.name
    
    func install(completion:(success:Bool) -> ()) -> NSTask? {
        let archivePath = NSBundle.mainBundle().pathForResource("node.tar", ofType: "gz")!
        let pathAddScriptPath = NSBundle.mainBundle().pathForResource("add-paths", ofType: "sh")!
        var term = Terminal()
        term.workingDirectory = "~"
        let command = "mkdir -p ~/local && " +
                      "tar -xf '\(archivePath)' -C ~/local --strip-components=1 && " +
                      "'\(pathAddScriptPath)'"
        
        return term.runTerminalCommandAsync(command, showOutput: false) { (result) -> () in
            completion(success: result != nil)
        }
    }
    
    func installIfNeeded(completion:(success:Bool) -> ()) -> NSTask? {
        if Node.isInstalled() {
            completion(success: true)
        } else {
            var node = Node()
            return node.install({ (success) -> () in
                completion(success: success)
            })
        }
        return nil
    }
}
