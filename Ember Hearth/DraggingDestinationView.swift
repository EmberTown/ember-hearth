//
//  DraggingDestinationView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 17.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

protocol DraggingDestinationViewDelegate {
    func folderDropped(paths: [String])
}

class DraggingDestinationView: BGColorView, NSDraggingDestination {
    var delegate: DraggingDestinationViewDelegate?
    
    // MARK: NSDraggingDestination
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        
        if let window = self.window {
            self.alphaValue = 0.7
        }
        
        return NSDragOperation.Generic
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        self.alphaValue = 0
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        self.alphaValue = 0
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let paths: AnyObject? = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType)
        
        if let paths = paths as? [String] {
                self.delegate?.folderDropped(paths)
            return true
        }
        return false
    }
}
