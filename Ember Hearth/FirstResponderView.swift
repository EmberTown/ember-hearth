//
//  FirstResponderView.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 09.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class FirstResponderView: BGColorView {
    var textView = NSTextView()
    override var acceptsFirstResponder: Bool {return true}
}
