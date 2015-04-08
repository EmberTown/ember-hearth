//
//  Brew.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 08.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Brew {
    class func isInstalled(tool: String) -> Bool {
        var versions = installedVersions(tool)
        if versions == nil {
            return false
        }
        return versions!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
    }
    
    class func installedVersions(tool: String) -> String? {
        var terminal = Terminal()
        return terminal.runTerminalCommandSync("brew ls --versions \(tool)")
    }
}
