//
//  ViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func installNode (sender: AnyObject) {
        var node = Node()
        node.install { (success) -> () in
            println("Installed node with success: \(success)")
        }
    }
    
    @IBAction func installNPM (sender: AnyObject) {
        var npm = NPM()
        npm.install { (success) -> () in
            println("Installed npm with success: \(success)")
        }
    }
    
    @IBAction func installEmberCLI (sender: AnyObject) {
        var ember = EmberCLI()
        ember.install { (success) -> () in
            println("Installed Ember CLI with success: \(success)")
        }
    }
    
    @IBAction func installBower (sender: AnyObject) {
        var bower = Bower()
        bower.install { (success) -> () in
            println("Installed Ember CLI with success: \(success)")
        }
    }
    
    @IBAction func nodeVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = Node.version()
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    @IBAction func npmVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = NPM.version()
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    @IBAction func bowerVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = Bower.version()
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    @IBAction func emberCLIVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = EmberCLI.version()
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
}

