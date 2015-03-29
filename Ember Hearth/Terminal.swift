//
//  Terminal.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Terminal {
    private var task: NSTask?
    private var output: NSPipe?
    var workingDirectory: String?
    
    init() { }
    
    func taskForCommand (command: String) -> NSTask {
        var task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["-l", "-c", command]
        return task
    }
    
    func runTerminalCommandSync (command: String) -> String? {
        var task = taskForCommand(command)
        
        var findOut = NSPipe()
        task.standardOutput = findOut
        
        task.launch()
        task.waitUntilExit()
        
        let outData = findOut.fileHandleForReading.readDataToEndOfFile()
        let result = NSString(data: outData, encoding: NSASCIIStringEncoding)
        return result
    }
    
    func runTerminalCommandAsync (command: String, completion: (result: String?) -> ()) {
        self.task = taskForCommand(command)
        if self.workingDirectory != nil {
            self.task?.currentDirectoryPath = self.workingDirectory!
        }
        self.output = NSPipe()
        self.task?.standardOutput = self.output!
        
        self.task?.terminationHandler = { (task: NSTask!) in
            
            if task.terminationStatus != 0 {
                completion(result: nil)
            } else {
                let outData = self.output?.fileHandleForReading.readDataToEndOfFile()
                var result: NSString?
                if outData != nil {
                    result = NSString(data: outData!, encoding: NSASCIIStringEncoding)
                }
                completion(result: result)
            }
            
            self.task = nil
            self.output = nil
        }
        self.task?.launch()
    }
}
