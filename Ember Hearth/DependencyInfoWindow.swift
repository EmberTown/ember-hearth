//
//  DependencyInfoWindow.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 12.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

enum DependencyInfoWindowButton {
    case OKButton
    case CancelButton
}

protocol DependencyInfoWindowDelegate {
    func buttonClicked(button: DependencyInfoWindowButton)
}

class DependencyInfoWindow: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet private var tableView: NSTableView?
    @IBOutlet private var okButton: NSButton?
    @IBOutlet private var cancelButton: NSButton?
    @IBOutlet private var infoLabel: NSTextField?
    
    var dependencies: [DependencyAvailability]? {
        didSet {
            println("Dependencies updated with \(dependencies?.count)")
            self.tableView?.reloadData()
        }
    }
    
    var infoText = "" {
        didSet {
            infoLabel?.stringValue = infoText
        }
    }
    
    var delegate: DependencyInfoWindowDelegate?
    var shouldShowCancelButton = true
    var okButtonEnabled = true {
        didSet {
            okButton?.enabled = okButtonEnabled
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        cancelButton?.hidden = !shouldShowCancelButton
        okButton?.enabled = okButtonEnabled
        self.tableView?.reloadData()
    }

    func updateDependency(dependency: DependencyAvailability) {
        if let dependencies = self.dependencies {
            if let index = find(dependencies, dependency) {
                let indexSet = NSIndexSet(index: index)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView?.reloadDataForRowIndexes(indexSet, columnIndexes: NSIndexSet(index: 0))
                })
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let dependencies = self.dependencies {
            return dependencies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view = tableView.makeViewWithIdentifier("dependencyCell", owner: tableView) as! DependencyWindowCellView
        if let dependency = dependencies?[row] {
            view.textField?.stringValue = dependency.name
            view.available = dependency.available
        }
        return view
    }
    
    @IBAction func buttonClicked(sender: AnyObject?) {
        if sender as? NSButton == okButton {
            delegate?.buttonClicked(.OKButton)
        } else if sender as? NSButton == cancelButton {
            delegate?.buttonClicked(.CancelButton)
        }
        
        self.window!.orderOut(self)
        NSApplication.sharedApplication().mainWindow!.endSheet(self.window!)
    }
}
