//
//  Watchman.swift
//  Ember Hearth
//
//  Created by Vinnie1991 on 30.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Watchman: CLITool {
    class func isInstalled() -> Bool {
        return Watchman.version() != nil
    }

    class func path() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("which watchman")
    }

    class func version() -> String? {
        var term = Terminal()
        return term.runTerminalCommandSync("watchman -v")
    }

    static let name = "Watchman"
    let name: String = Watchman.name

    func install(completion:(success:Bool) -> ()) -> NSTask? {
        var term = Terminal()
        return term.runTerminalCommandAsync("brew install watchman", completion: { (result) -> () in
            completion(success:result != nil)
        })
    }

    func installIfNeeded(completion:(success:Bool) -> ()) -> NSTask? {
        if Watchman.isInstalled() {
            completion(success: true)
        } else {
            return self.install({ (success) -> () in
                completion(success: success)
            })
        }
        return nil
    }

    func update(completion:(success:Bool) -> ()) -> NSTask? {
        return self.install(completion)
    }
}