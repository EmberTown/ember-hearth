//
//  SectionView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 18.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@IBDesignable
class SectionView: DropZoneView {
    @IBInspectable var title: String = "Title"
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        var string = NSMutableAttributedString(string: title)
        
        self.backgroundColor.drawSwatchInRect(NSMakeRect(40, self.frame.size.height - inset - lineWidth, string.size.width + 20, lineWidth*4))
        
        
        string.drawAtPoint(NSMakePoint(50, self.frame.size.height - 27))
        
        
    }
    
    func configure() {
        self.lineWidth = 1
        self.lineSpacing = 0
        self.inset = 20
        self.borderRadius = 15
        self.lineColor = NSColor(white: 0.8, alpha: 1)
    }
}
