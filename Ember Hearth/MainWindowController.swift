//
//  MainWindowController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 16.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate, NSDraggingDestination {
    var overlay: FirstResponderView?

    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.window?.registerForDraggedTypes([NSFilenamesPboardType])
        self.window?.delegate = self
    }
    
    
    // MARK: NSDraggingDestination
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        println("DraggingEntered")
        
        if let window = self.window {
            self.overlay = FirstResponderView(frame:NSMakeRect(0, 0, window.frame.size.width, window.frame.size.height))
            self.overlay?.backgroundColor = NSColor(white: 1, alpha: 1)
            self.overlay?.alphaValue = 0.7
            let view = window.contentView as? NSView
            self.overlay?.wantsLayer = true
            
            view?.addSubview(self.overlay!)
        }
        
        return NSDragOperation.Generic
    }
    
    func draggingExited(sender: NSDraggingInfo?) {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
        self.window?.alphaValue = 1
    }
    
    func draggingEnded(sender: NSDraggingInfo?) {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
        self.window?.alphaValue = 1
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let paths: AnyObject? = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType)
        
        println("Got paths")
        
        if let paths = paths as? [String] {
//            self.dragDelegate?.folderDropped(paths)
            return true
        }
        return false
    }
}
