//
//  ColoredTabView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 26.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@IBDesignable
class ColoredTabView: NSTabView {
    
    @IBInspectable var backgroundColor: NSColor = NSColor.whiteColor()
    
    override func drawRect(dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFill(dirtyRect)
        super.drawRect(dirtyRect)
    }
}
