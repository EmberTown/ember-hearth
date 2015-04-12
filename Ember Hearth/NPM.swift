//
//  NPM.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class NPM: CLITool {
    class func isInstalled () -> Bool {
        return version() != nil
    }
    
    class func path() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("which npm")
    }
    
    class func version () -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("npm -v")
    }
    
    static let name = "NPM"
    let name: String = Node.name
    
    func install (completion: (success: Bool) -> ()) {
        let scriptPath = NSBundle.mainBundle().pathForResource("install-npm", ofType: "sh")
        
        var term = Terminal()
        term.runTerminalCommandAsync("\"\(scriptPath!)\"", showOutput:false, completion: { (result) -> () in
            completion(success: result != nil)
        })
    }
    
    func installIfNeeded(completion:(success:Bool) -> ()) {
        if NPM.isInstalled() {
            completion(success: true)
        } else {
            var npm = NPM()
            npm.install({ (success) -> () in
                completion(success: success)
            })
        }
    }
}
