//
//  ProjectNameWindowController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

protocol ProjectNameWindowDelegate {
    func nameSet(name: String)
}

class ProjectNameWindowController: NSWindowController {
    var delegate: ProjectNameWindowDelegate?

    @IBOutlet var textField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @IBAction func cancel(sender: AnyObject?) {
        self.window?.orderOut(nil)
        self.window!.endSheet(self.window!)
    }
    
    @IBAction func save(sender: AnyObject?) {
        self.delegate?.nameSet(self.textField.stringValue)
    }
}
