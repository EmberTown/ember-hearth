//
//  ProjectViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {
    var serverTask: NSTask?
    @IBOutlet var runButton: NSButton!
    @IBOutlet var titleLabel: NSTextField!

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setProjectTitle:", name: "activeProjectSet", object: nil)
    }

    @IBAction func runServer (sender: AnyObject) {
        if serverTask != nil {
            stopServer()
        } else {
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            if appDelegate.activeProject != nil {
                runButton.title = "Stop Ember server"
                var ember = EmberCLI()
                let project = appDelegate.activeProject!
                let path: String = project.path!
                serverTask = ember.runServerTask(path)
                var pipe = NSPipe()
                serverTask?.standardOutput = pipe
                serverTask?.terminationHandler = { (task: NSTask!) in
                    if task.terminationStatus > 0 {
                        let result = pipe.fileHandleForReading.readDataToEndOfFile()
                        if result.length > 0 {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                var alert = NSAlert()
                                let string = NSString(data: result, encoding:NSASCIIStringEncoding)
                                alert.messageText = "Error starting server"
                                if string?.length > 400 {
                                    alert.informativeText = "\(string!.substringToIndex(400))…"
                                } else {
                                    alert.informativeText = string as? String
                                }
                                alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                                self.stopServer()
                            })
                        }
                    }
                }
                serverTask?.launch()
            }
        }
    }

    func stopServer() {
        serverTask?.terminate()
        serverTask = nil
        runButton.title = "Run Ember server"
    }

    func setProjectTitle(notification: NSNotification) {
        var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let project = appDelegate.activeProject
        let name = project?.name
        if name != nil {
            self.titleLabel.stringValue = name!
        }
        NSApplication.sharedApplication().mainWindow!.firstResponder.resignFirstResponder()
    }

    override func viewWillDisappear() {
        println("Closing server")
        serverTask?.terminate()
    }
}
