//
//  PaddedTextFieldCell.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 07.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

// Couldn't figure out what redraw function to call in didSet on each var to make this an IBDesignable.
class PaddedTextFieldCell: NSTextFieldCell {
    var paddingLeft: CGFloat = 10.0
    var paddingRight: CGFloat = 10.0
    var paddingTop: CGFloat = 15.0
    var paddingBottom: CGFloat = 5.0
    
    
    override func drawingRectForBounds(theRect: NSRect) -> NSRect {
        let inset = NSMakeRect(theRect.origin.x + paddingLeft, theRect.origin.y + paddingTop, theRect.size.width - paddingLeft - paddingRight, theRect.size.height - paddingTop - paddingBottom)
        return inset
    }
}
