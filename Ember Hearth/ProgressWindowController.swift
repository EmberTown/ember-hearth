//
//  ProgressWindowController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

protocol ProgressWindowDelegate {
    func progressWindowCancelled()
}

class ProgressWindowController: NSWindowController {
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var label: NSTextField!
    
    var delegate: ProgressWindowDelegate?
    
    @IBAction func cancel(sender: AnyObject?) {
        self.delegate?.progressWindowCancelled()
        self.window?.orderOut(sender)
        self.window?.parentWindow?.endSheet(self.window!)
    }
}
