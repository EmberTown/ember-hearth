//
//  ProjectTabViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 07.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

// Note: We tried making this an IBInspectable, but that doesn't seem to work for layout constraints, at least not for implicit views.
class ProjectTabViewController: NSTabViewController {
    
    var topSpacing: Float = 20.0 {
        didSet {
            setTopConstraintConstant(topSpacing)
        }
    }
    
    var topConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTopConstraintConstant(topSpacing)
        
        var bgView = BGColorView(backgroundColor: NSColor.whiteColor())
        bgView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bgView)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[bgView]-0-|", options: nil, metrics: nil, views: ["bgView":bgView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bgView]-0-|", options: nil, metrics: nil, views: ["bgView":bgView]))
    }
    
    override func viewWillAppear() {
        setTopConstraintConstant(topSpacing)
    }
    
    func setTopConstraintConstant(constant: Float) {
        if self.topConstraint == nil {
            var view = self.view as NSView
            self.topConstraint = NSLayoutConstraint(item: self.tabView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: CGFloat(constant))
            view.addConstraint(self.topConstraint!)
        }
        
        self.topConstraint?.constant = CGFloat(constant)
    }
    
}
