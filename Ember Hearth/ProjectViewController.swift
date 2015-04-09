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
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setProjectTitle:", name: "activeProjectSet", object: nil)
    }

    @IBAction func runServer (sender: AnyObject) {
        var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        if serverTask != nil {
            stopServer()
            if appDelegate.activeProject != nil {
                appDelegate.activeProject!.serverRunning = false
                NSNotificationCenter.defaultCenter().postNotificationName("serverStopped", object: nil)
            }
        } else {
            if appDelegate.activeProject != nil {
                runButton.title = "Stop Ember server"
                var ember = EmberCLI()
                let project = appDelegate.activeProject!
                let path: String = project.path!
                serverTask = ember.runServerTask(path)
                var pipe = NSPipe()
                serverTask?.standardOutput = pipe
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedData:", name:NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading)
                
                serverTask?.terminationHandler = { (task: NSTask!) in
                    self.serverTerminated(task, project: project)
                }
                serverTask?.launch()
            }
        }
    }
    
    func serverTerminated(task: NSTask, project: Project) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: self.serverTask)
        let pipe = task.standardOutput as! NSPipe
        if task.terminationStatus > 0 {
            let result = pipe.fileHandleForReading.readDataToEndOfFile()
            if result.length > 0 && project.serverRunning {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    project.serverRunning = false
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
                        var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.activeProject!.serverRunning = true
                        NSNotificationCenter.defaultCenter().postNotificationName("serverStarted", object: nil)
                    }
                }
            } else { // End of file
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: self.serverTask)
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
        
        NSApplication.sharedApplication().mainWindow!.makeFirstResponder(self.view)
    }

    override func viewWillDisappear() {
        println("Closing server")
        serverTask?.terminate()
    }
    
    
}
