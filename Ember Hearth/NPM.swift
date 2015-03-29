//
//  NPM.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class NPM {
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
    
    func install (completion: (success: Bool) -> ()) {
        let scriptPath = NSBundle.mainBundle().pathForResource("install-npm", ofType: "sh")
        
        var term = Terminal()
        term.runTerminalCommandAsync("\"\(scriptPath!)\"", completion: { (result) -> () in
            completion(success: result != nil)
        })
    }
}
