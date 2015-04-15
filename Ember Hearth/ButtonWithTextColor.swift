//
//  buttonWithTextColor.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 14.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@IBDesignable
class ButtonWithTextColor: NSButton {
    @IBInspectable var textColor: NSColor = NSColor.blackColor() {
        didSet {
            self.title = self.attributedTitle.string
        }
    }
    override var title: String {
        set {
            var attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, attributedString.length))
            var style = NSMutableParagraphStyle()
            style.alignment = .CenterTextAlignment
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSBaselineOffsetAttributeName, value: -1, range: NSMakeRange(0, attributedString.length))
            self.attributedTitle = attributedString
        }
        get {
            return self.attributedTitle.string
        }
    }
}
