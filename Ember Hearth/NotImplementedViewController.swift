//
//  NotImplementedViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 07.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class NotImplementedViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func openGithubProject (sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/EmberTown/ember-hearth")!)
    }
}
