//
//  ProjectStatisticsViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 09.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectStatisticsViewController: NSViewController {

    @IBOutlet var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStats:", name: "activeProjectSet", object: nil)
        var delegate = NSApplication.sharedApplication().delegate! as! AppDelegate
        if delegate.activeProject != nil {
            refreshStats(nil)
        }
    }
    
    func refreshStats(notification: NSNotification?) {
        label.stringValue = ""
        
        var delegate = NSApplication.sharedApplication().delegate! as! AppDelegate
        var project = delegate.activeProject
        
        var terminal = Terminal()
        let creationTime = terminal.runTerminalCommandSync("GetFileInfo -d \"\(project!.path!)\"")
        if creationTime != nil {
            label.stringValue += "Created at \(creationTime!)"
        }
        
        let appPath = "\(project!.path!)/app"
        terminal = Terminal()
        terminal.runTerminalCommandAsync("find \"\(appPath)\" -name \"*.js\" | wc -l", completion: { (result) -> () in
            let count = result?.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            if count != nil && count!.toInt() > 0 {
                self.label.stringValue += "\(count!) javascript files\n"
            }
        })
        
        terminal = Terminal()
        terminal.runTerminalCommandAsync("find \"\(appPath)\" -name \"*.coffee\" | wc -l", completion: { (result) -> () in
            let count = result?.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            if count != nil && count!.toInt() > 0 {
                self.label.stringValue += "\(count!) coffeescript files\n"
            }
        })
        
        terminal = Terminal()
        terminal.runTerminalCommandAsync("find \"\(appPath)\" -name \"*.hbs\" | wc -l", completion: { (result) -> () in
            let count = result?.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            if count != nil && count!.toInt() > 0 {
                self.label.stringValue += "\(count!) template files\n"
            }
        })
        
        terminal = Terminal()
        terminal.runTerminalCommandAsync("find \"\(appPath)\" -name \"*.css\" | wc -l", completion: { (result) -> () in
            let count = result?.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            if count != nil && count!.toInt() > 0 {
                self.label.stringValue += "\(count!) css files\n"
            }
        })
        
        terminal = Terminal()
        terminal.runTerminalCommandAsync("find \"\(appPath)\" -name \"*.scss\" | wc -l", completion: { (result) -> () in
            let count = result?.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            if count != nil && count!.toInt() > 0 {
                self.label.stringValue += "\(count!) scss files\n"
            }
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
