//
//  Node.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Node {
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
    
    func install(completion:(success:Bool) -> ()) {
        let scriptPath = NSBundle.mainBundle().pathForResource("install-node", ofType: "sh")
        
        var term = Terminal()
        term.runTerminalCommandAsync("\"\(scriptPath!)\"", completion: { (result) -> () in
            completion(success: result != nil)
        })
    }
}
