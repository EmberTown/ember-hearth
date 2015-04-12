//
//  ProjectViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {
    @IBOutlet var runButton: NSButton!
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    let runServerString = "Run Ember server"
    let stopServerString = "Stop Ember server"
    var serverOutput = ""
    
    var project: Project? {
        get {
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.activeProject
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "projectChanged:", name: "activeProjectSet", object: nil)
        if project != nil {
            self.projectChanged(nil)
        }
    }

    @IBAction func runServer (sender: AnyObject) {
        if project?.serverTask != nil {
            stopServer()
            project?.serverStatus = .stopped
        } else if project != nil {
            // Stop all servers
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.stopAllServers()
            
            project?.serverStatus = .booting
            
            runButton.enabled = false
            progressIndicator.startAnimation(self)
            progressIndicator.hidden = false
            runButton.title = stopServerString
            
            var ember = EmberCLI()
            let path: String = project!.path!
            project?.serverTask = ember.runServerTask(path)
            var pipe = NSPipe()
            project?.serverTask?.standardOutput = pipe
            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedData:", name:NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading)
            
            project?.serverTask?.terminationHandler = { (task: NSTask!) in
                self.serverTerminated(task, project: self.project)
            }
            project?.serverTask?.launch()
        }
    }
    
    func serverTerminated(task: NSTask, project: Project?) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: task)
        let pipe = task.standardOutput as! NSPipe
        if task.terminationStatus > 0 {
            if project != nil && !runButton.enabled { // Ad hoc check for if server was interupted before it started
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    project?.serverStatus = .errored
                    var alert = NSAlert()
                    alert.messageText = "Error starting server"
                    var info = self.serverOutput as NSString
                    if info.length > 400 {
                        info = info.substringToIndex(400)
                    }
                    alert.informativeText = info as String
                    alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                    self.stopServer()
                })
            }
        }
    }
    
    func receivedData(notification: NSNotification?) {
        var fileHandle = notification?.object as? NSFileHandle
        if let data = fileHandle?.availableData {
            if data.length > 0 {
                fileHandle?.waitForDataInBackgroundAndNotify()
                if let string = NSString(data: data, encoding:NSUTF8StringEncoding) {
                    self.serverOutput += string as String
                    let range = string.rangeOfString("Serving on ")
                    if range.location != NSNotFound {
                        serverStarted()
                    }
                }
            } else { // End of file
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: project?.serverTask)
            }
        }
    }
    
    func serverStarted() {
        runButton.enabled = true
        progressIndicator.hidden = true
        progressIndicator.stopAnimation(self)
        project?.serverStatus = .running
    }

    func stopServer() {
        self.serverOutput = ""
        runButton.enabled = true
        progressIndicator.hidden = true
        progressIndicator.stopAnimation(self)
        project?.stopServer()
        runButton.title = "Run Ember server"
    }

    func projectChanged(notification: NSNotification?) {
        setProjectTitle(notification)
        if project != nil && project!.serverStatus == .running {
            runButton.title = stopServerString
        } else {
            runButton.title = runServerString
        }
    }
    
    func setProjectTitle(notification: NSNotification?) {
        if let name = project?.name {
            self.titleLabel.stringValue = name
        }
        
        NSApplication.sharedApplication().mainWindow?.makeFirstResponder(self.view)
    }

    override func viewWillDisappear() {
        println("Closing server")
        stopServer()
    }
    
    
}
