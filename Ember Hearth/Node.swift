//
//  Node.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class Node {
    class func isInstalled() -> Bool {
        return Node.version() != nil
    }
    
    class func path() -> String? {
        var findNodeTask = NSTask()
        findNodeTask.launchPath = "/bin/bash"
        findNodeTask.arguments = ["-l", "-c", "which node"]
        
        var findOut = NSPipe()
        findNodeTask.standardOutput = findOut
        
        findNodeTask.launch()
        findNodeTask.waitUntilExit()
        
        let outData = findOut.fileHandleForReading.readDataToEndOfFile()
        let path = NSString(data: outData, encoding: NSASCIIStringEncoding)
        
        println("Path: \(path)")
        
        return path
    }
    
    class func version() -> String? {
        var checkNodeVersion = NSTask()
        checkNodeVersion.launchPath = "/bin/bash"
        checkNodeVersion.arguments = ["-l", "-c", "node -v"]
        
        var checkOut = NSPipe()
        checkNodeVersion.standardOutput = checkOut
        
        checkNodeVersion.launch()
        checkNodeVersion.waitUntilExit()
        
        let checkData = checkOut.fileHandleForReading.readDataToEndOfFile()
        
        let version = NSString(data: checkData, encoding: NSUTF8StringEncoding)
        
        println("Version: \(version)")
        
        if version?.length > 0 {
            return version
        }
        return nil
    }
    
    class func install(completion:(success:Bool) -> ()) {
        let scriptPath = NSBundle.mainBundle().pathForResource("install-node", ofType: "sh")
        
        var installNode = NSTask()
        installNode.launchPath = "/bin/bash"
        installNode.arguments  = ["-l", "-c", "\"\(scriptPath!)\""]
        
        installNode.launch()
        installNode.terminationHandler = { (task: NSTask!) -> Void in
            completion(success: task.terminationStatus == 0)
        }
        
    }
}
