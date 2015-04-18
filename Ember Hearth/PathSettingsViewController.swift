//
//  PathSettingsViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 10.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
import MASPreferences

class PathSettingsViewController: NSViewController, MASPreferencesViewController {

    @IBOutlet var nodePathTextField: NSTextField!
    @IBOutlet var npmPathTextField: NSTextField!
    @IBOutlet var bowerPathTextField: NSTextField!
    @IBOutlet var phantomJSPathTextField: NSTextField!
    @IBOutlet var emberCLIPathTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nodePathTextField.placeholderString = Node.path()
        npmPathTextField.placeholderString = NPM.path()
        bowerPathTextField.placeholderString = Bower.path()
        phantomJSPathTextField.placeholderString = PhantomJS.path()
        emberCLIPathTextField.placeholderString = EmberCLI.path()
    }
 
    // MARK: MASPreferencesViewController
    var toolbarItemImage = NSImage(named: "NSListViewTemplate")
    var toolbarItemLabel = "Paths"
}
