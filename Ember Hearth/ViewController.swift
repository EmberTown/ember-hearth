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
        Node.install { (success) -> () in
            println("Installed node with success: \(success)")
        }
    }
    
    @IBAction func installNPM (sender: AnyObject) {
        NPM.install { (success) -> () in
            println("Installed npm with success: \(success)")
        }
    }
}

