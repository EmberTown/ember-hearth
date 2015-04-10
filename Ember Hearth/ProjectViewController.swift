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
    
    let runServerString = "Run Ember server"
    let stopServerString = "Stop Ember server"
    
    var project: Project? {
        get {
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.activeProject
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "projectChanged:", name: "activeProjectSet", object: nil)
    }

    @IBAction func runServer (sender: AnyObject) {
        if project?.serverTask != nil {
            stopServer()
            project?.serverRunning = false
            NSNotificationCenter.defaultCenter().postNotificationName("serverStopped", object: nil)
        } else if project != nil {
            // Stop all servers
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.stopAllServers()
            
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
            let result = pipe.fileHandleForReading.readDataToEndOfFile()
            if result.length > 0 && project != nil && project!.serverRunning {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    project?.serverRunning = false
                    NSNotificationCenter.defaultCenter().postNotificationName("serverStopped", object: nil)
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
    
    func receivedData(notification: NSNotification?) {
        var fileHandle = notification?.object as? NSFileHandle
        if let data = fileHandle?.availableData {
            if data.length > 0 {
                fileHandle?.waitForDataInBackgroundAndNotify()
                if let string = NSString(data: data, encoding:NSUTF8StringEncoding) {
                    let range = string.rangeOfString("Serving on ")
                    if range.location != NSNotFound {
                        project?.serverRunning = true
                        NSNotificationCenter.defaultCenter().postNotificationName("serverStarted", object: nil)
                    }
                }
            } else { // End of file
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: project?.serverTask)
            }
        }
    }

    func stopServer() {
        project?.stopServer()
        runButton.title = "Run Ember server"
    }

    func projectChanged(notification: NSNotification) {
        setProjectTitle(notification)
        if project != nil && project!.serverRunning {
            runButton.title = stopServerString
        } else {
            runButton.title = runServerString
        }
    }
    
    func setProjectTitle(notification: NSNotification) {
        if let name = project?.name {
            self.titleLabel.stringValue = name
        }
        
        NSApplication.sharedApplication().mainWindow!.makeFirstResponder(self.view)
    }

    override func viewWillDisappear() {
        println("Closing server")
        stopServer()
    }
    
    
}
