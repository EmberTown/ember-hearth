//
//  PhantomJS.swift
//  Ember Hearth
//
//  Created by Kim Røen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class PhantomJS: CLITool {
    class func isInstalled() -> Bool {
        return PhantomJS.version() != nil
    }
    
    class func path() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("which phantomjs")
    }
    
    class func version() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("phantomjs -v")
    }
    
    static let name = "PhantomJS"
    let name: String = Node.name
    
    func install(completion:(success:Bool) -> ()) -> NSTask? {
        var term = Terminal()
        return term.runTerminalCommandAsync("npm install -g phantomjs", completion: { (result) -> () in
            completion(success:result != nil)
        })
    }
    
    func installIfNeeded(completion:(success:Bool) -> ()) -> NSTask? {
        if PhantomJS.isInstalled() {
            completion(success: true)
        } else {
            return self.install({ (success) -> () in
                completion(success: success)
            })
        }
        return nil
    }
}