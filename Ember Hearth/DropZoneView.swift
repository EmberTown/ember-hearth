//
//  DropZoneView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 17.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@IBDesignable
class DropZoneView: NSView {
    @IBInspectable var lineColor: NSColor = NSColor.blackColor()

    @IBInspectable var lineWidth: CGFloat = 5.0
    @IBInspectable var lineLength: CGFloat = 10.0
    @IBInspectable var lineSpacing: CGFloat = 5.0
    
    @IBInspectable var inset: CGFloat = 5.0
    @IBInspectable var borderRadius: CGFloat = 15.0
    
    @IBInspectable var alpha: CGFloat = 1.0 {
        didSet {
            self.alphaValue = alpha
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let bounds = self.bounds
        
        let insetRect = NSMakeRect(bounds.origin.x + inset, bounds.origin.y + inset, bounds.size.width - inset * 2, bounds.size.height - inset * 2)
        
        var path = NSBezierPath(roundedRect: insetRect, xRadius: borderRadius, yRadius: borderRadius)
        path.lineWidth = lineWidth
        
        let pattern = [lineLength, lineSpacing]
        
        path.setLineDash(pattern, count: pattern.count, phase: 0)
        lineColor.set()
        path.stroke()
    }
    
}
