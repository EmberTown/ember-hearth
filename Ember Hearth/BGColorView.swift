//
//  BGColorView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@IBDesignable
class BGColorView: NSView {

    @IBInspectable var backgroundColor: NSColor = NSColor.whiteColor() {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFill(dirtyRect)
        super.drawRect(dirtyRect)
    }
    
    convenience init(backgroundColor:NSColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
}
