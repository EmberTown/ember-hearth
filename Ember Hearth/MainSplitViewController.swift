//
//  MainSplitViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 12.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController {
    var overlay: BGColorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleSecondPane", name: "activeProjectSet", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleSecondPane", name: "noActiveProject", object: nil)
        self.view.window?.setAnchorAttribute(.Leading, forOrientation: .Horizontal)
        toggleSecondPane()
        
        let secondSplitViewItem: NSSplitViewItem? = self.splitViewItems[1] as? NSSplitViewItem
        
        let rightView = secondSplitViewItem?.viewController.view
        
        overlay = BGColorView()
        overlay.alphaValue = 0
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.wantsLayer = true
        rightView?.addSubview(overlay)
        rightView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[overlay]-0-|", options: nil, metrics: nil, views: ["overlay":overlay]))
        rightView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[overlay]-0-|", options: nil, metrics: nil, views: ["overlay":overlay]))
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showOverlay:", name: "dragEntered", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideOverlay:", name: "dragEnded", object: nil)
    }
    
    // MARK: Overlays
    func showOverlay(notification: NSNotification?) {
        self.overlay.alphaValue = 0.5
    }
    
    func hideOverlay(notification: NSNotification?) {
        self.overlay.alphaValue = 0
    }
    
    // MARK: Toggling second pane
    func toggleSecondPane() {
        if self.view.window?.sheets.count > 0 {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.toggle(true)
            }
        } else {
            toggle(false)
        }
    }
    
    func toggle(animate: Bool) {
        let secondItem = self.splitViewItems[1] as? NSSplitViewItem
        let delegate = NSApplication.sharedApplication().delegate as? AppDelegate
        if delegate?.activeProject != nil {
            if animate {
                secondItem?.animator().collapsed = false
            } else {
                secondItem?.collapsed = false
            }
            
            secondItem?.canCollapse = false
        } else {
            secondItem?.canCollapse = true
            secondItem?.animator().collapsed = true
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "activeProjectSet", object: nil)
    }
}
