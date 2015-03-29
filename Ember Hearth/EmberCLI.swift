//
//  EmberCLI.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class EmberCLI {
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
}
