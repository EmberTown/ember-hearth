//
//  Bower.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Bower: CLITool {
    class func isInstalled () -> Bool {
        return version() != nil
    }
    
    class func path() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("which bower")
    }
    
    class func version () -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("bower -v")
    }
    
    func install (completion: (success: Bool) -> ()) {
        var term = Terminal()
        term.runTerminalCommandAsync("npm install -g bower", completion: { (result) -> () in
            completion(success:result != nil)
        })
    }
    
    func installIfNeeded(completion:(success:Bool) -> ()) {
        if Bower.isInstalled() {
            completion(success: true)
        } else {
            var bower = Bower()
            bower.install({ (success) -> () in
                completion(success: success)
            })
        }
    }
}
