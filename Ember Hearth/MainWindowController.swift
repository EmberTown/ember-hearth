//
//  MainWindowController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 16.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate, DraggingDestinationViewDelegate {
    var overlay: DraggingDestinationView?

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.overlay = DraggingDestinationView()
        self.overlay?.registerForDraggedTypes([NSFilenamesPboardType])
        self.overlay?.alphaValue = 0
        self.overlay?.translatesAutoresizingMaskIntoConstraints = false
        self.overlay?.backgroundColor = NSColor(white: 1, alpha: 1)
        self.overlay?.wantsLayer = true
        self.window?.contentView.addSubview(self.overlay!)
        self.window?.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[overlay]-0-|", options: nil, metrics: nil, views: ["overlay":self.overlay!]))
        self.window?.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[overlay]-0-|", options: nil, metrics: nil, views: ["overlay":self.overlay!]))
    }
    
    // MARK: DraggingDestinationViewDelegate
    func folderDropped(paths: [String]) {
        for path in paths {
            ProjectController.sharedInstance.addProject(path, name: nil, runEmberInstall: false)
        }
    }
}
