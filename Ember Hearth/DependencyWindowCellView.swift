//
//  DependencyWindowCellView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 12.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class DependencyWindowCellView: NSTableCellView {
    @IBOutlet private var loadingIndicator: NSProgressIndicator!
    var available: Bool? {
        didSet {
            
            if loadingIndicator.hidden && available == nil {
                loadingIndicator.startAnimation(nil)
                loadingIndicator.hidden = false
            } else if !loadingIndicator.hidden {
                loadingIndicator.stopAnimation(nil)
                loadingIndicator.hidden = true
            }

            if available == nil {
                imageView?.image = nil
            } else if available! == true {
                imageView?.image = NSImage(named: "NSStatusAvailable")
            } else {
                imageView?.image = NSImage(named: "NSStatusUnavailable")
            }
        }
    }
}
