//
//  RadialGradientView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@IBDesignable
class RadialGradientView: NSView {
    
    @IBInspectable var startingColor: NSColor = NSColor(white: 1, alpha: 0.1) {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    @IBInspectable var endingColor: NSColor = NSColor(white: 1, alpha: 1) {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        var gradient = NSGradient(startingColor: startingColor, endingColor: endingColor)
        let center = NSPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        let maxSize = max(self.bounds.size.height, self.bounds.size.width)
        gradient.drawInRect(self.bounds, relativeCenterPosition: NSPoint(x: 0, y: 0))
    }
    
}
