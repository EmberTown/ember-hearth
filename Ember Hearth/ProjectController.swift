//
//  ProjectController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 13.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectController: NSObject {
    var project: Project? {
        get {
            var delegate = NSApplication.sharedApplication().delegate as? AppDelegate
            return delegate?.activeProject
        }
    }
    var serverOutput: String = ""
    
    @IBAction func createProject(sender: AnyObject) {
        
    }
    
    @IBAction func openProject(sender: AnyObject) {
        
    }
    
    @IBAction func runServer(sender: AnyObject) {
        if project?.serverTask != nil {
            stopServer(nil)
            project?.serverStatus = .stopped
        } else if project != nil {
            // Stop all servers
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.stopAllServers()
            
            serverOutput = ""
            
            project?.serverStatus = .booting
            
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
        let pipe = task.standardOutput as! NSPipe
        if task.terminationStatus > 0 {
            if project?.serverStatus == .booting { // Ad hoc check for if server was interupted before it started
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    project?.serverStatus = .errored
                    var alert = NSAlert()
                    alert.messageText = "Error starting server"
                    var info = self.serverOutput as NSString
                    if info.length > 400 {
                        info = info.substringToIndex(400)
                    }
                    alert.informativeText = info as String
                    alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
                    self.stopServer(nil)
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
                        project?.serverStatus = .running
                    }
                }
            } else { // End of file
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: project?.serverTask)
            }
        }
    }
    

    @IBAction func stopServer(sender: AnyObject?) {
        project?.stopServer()
    }
}
