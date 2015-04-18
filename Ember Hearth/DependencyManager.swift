//
//  DependencyManager.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

protocol CLITool {
    func install(completion:(success:Bool) -> ()) -> NSTask?
    func installIfNeeded(completion:(success:Bool) -> ()) -> NSTask?
    var name: String {get}
}

protocol DependencyManagerDelegate {
    func startingTask(task: NSTask?)
}

class DependencyAvailability: Equatable {
    convenience init(type: Dependency, name: String, available: Bool?) {
        self.init()
        self.type = type
        self.name = name
        self.available = available
    }
    var type: Dependency!
    var name: String!
    var available: Bool? // Nil is valid as "not sure yet"
}

func ==(left: DependencyAvailability, right: DependencyAvailability) -> Bool {
    return left.type == right.type
}

enum Dependency {
    case Node
    case NPM
    case Bower
    case PhantomJS
    case Ember
}

class DependencyManager: DependencyInfoWindowDelegate {
    var progressBar: ProgressWindowController?
    var dependencyInfoWindow: DependencyInfoWindow?
    var completion: ((success:Bool) -> Void)?
    var delegate: DependencyManagerDelegate?
    
    func listDependencies () -> [DependencyAvailability] {
        return [
            DependencyAvailability(type: .Node, name:Node.name, available: nil),
            DependencyAvailability(type: .NPM, name:NPM.name, available: nil),
            DependencyAvailability(type: .Bower, name:Bower.name, available: nil),
            DependencyAvailability(type: .PhantomJS, name:PhantomJS.name, available: nil),
            DependencyAvailability(type: .Ember, name:EmberCLI.name, available: nil)
        ]
    }
    
    func checkAvailabilityForDependencies(dependencies:[DependencyAvailability], completedDependency:(dependency: DependencyAvailability) -> ()) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        var done = 0
        for dependency in dependencies {
            dispatch_async(dispatch_get_global_queue(priority, 0), { () -> Void in
                switch dependency.type! {
                case .Node:
                    dependency.available = Node.isInstalled()
                case .NPM:
                    dependency.available = NPM.isInstalled()
                case .Bower:
                    dependency.available = Bower.isInstalled()
                case .PhantomJS:
                    dependency.available = PhantomJS.isInstalled()
                case .Ember:
                    dependency.available = EmberCLI.isInstalled()
                }
                completedDependency(dependency: dependency)
            })
        }
    }
    
    func showDependencyStatus() {
        dependencyInfoWindow = DependencyInfoWindow(windowNibName: "DependencyInfoWindow")
        dependencyInfoWindow!.shouldShowCancelButton = false
        dependencyInfoWindow!.okButtonEnabled = false
        dependencyInfoWindow!.dependencies = listDependencies()
        
        var done = 0
        checkAvailabilityForDependencies(dependencyInfoWindow!.dependencies!, completedDependency: { (dependency) -> Void in
            self.dependencyInfoWindow?.updateDependency(dependency)
            done++
            if done == self.dependencyInfoWindow!.dependencies!.count {
                self.dependencyInfoWindow?.okButtonEnabled = true
            }
        })
        
        NSApplication.sharedApplication().mainWindow?.beginSheet(dependencyInfoWindow!.window!, completionHandler: nil)
    }
    
    func installDependencies(completion:(success:Bool) -> ()) {
        self.completion = completion
        dependencyInfoWindow = DependencyInfoWindow(windowNibName: "DependencyInfoWindow")
        dependencyInfoWindow!.shouldShowCancelButton = true
        dependencyInfoWindow!.okButtonEnabled = false
        dependencyInfoWindow!.dependencies = listDependencies()
        dependencyInfoWindow!.delegate = self
        
        var done = 0
        checkAvailabilityForDependencies(dependencyInfoWindow!.dependencies!, completedDependency: { (dependency) -> Void in
            self.dependencyInfoWindow?.updateDependency(dependency)
            done++
            if done == self.dependencyInfoWindow!.dependencies!.count {
                self.dependencyInfoWindow?.okButtonEnabled = true
                var remaining = 0
                var name = "" // Temp in case we have just 1
                for dependency in self.dependencyInfoWindow!.dependencies! {
                    if dependency.available == false { // Can be nil, therefore "== true"
                        remaining++
                        name = dependency.name
                    }
                }
                if remaining == 0 {
                    self.dependencyInfoWindow?.infoText = "All dependencies are available."
                } else if remaining == 1 {
                    self.dependencyInfoWindow?.infoText = "Ember Hearth will install \(name) automatically."
                } else {
                    self.dependencyInfoWindow?.infoText = "Ember Hearth will install \(remaining) missing  dependencies automatically."
                }
            }
        })
        
        NSApplication.sharedApplication().mainWindow?.beginSheet(dependencyInfoWindow!.window!, completionHandler: nil)
    }
    
    func buttonClicked(button: DependencyInfoWindowButton) {
        if button == DependencyInfoWindowButton.OKButton {
            var remaining: [Dependency] = []
            for dependency in self.dependencyInfoWindow!.dependencies! {
                if dependency.available == false { // Can be nil, therefore "== true"
                    remaining.append(dependency.type)
                }
            }
            
            if remaining.count > 0 {
                self.installDependeniesInOrder(remaining, totalCount: remaining.count, completion: completion!)
            } else {
                if let completion = self.completion {
                    completion(success: true)
                }
            }
        }
    }
    
    private func installDependeniesInOrder(dependencies: [Dependency], totalCount: Int, completion:(success:Bool) -> ()) {
        if self.progressBar == nil {
            self.progressBar = ProgressWindowController()
            NSBundle.mainBundle().loadNibNamed("ProgressPanel", owner: self.progressBar, topLevelObjects: nil)
        }
        
        let dependency = dependencies[0]
        var tool = initializedToolForDependency(dependency)

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if dependency == .Node {
                self.progressBar?.label.stringValue = "Installing Node.js and NPM…"
            } else if dependency == .NPM {
                self.progressBar?.label.stringValue = "Updating \(tool.name)…"
            } else {
                self.progressBar?.label.stringValue = "Installing \(tool.name)…"
            }
            println("\(self.progressBar?.label.stringValue)")
            if self.progressBar?.window?.sheetParent == nil {
                NSApplication.sharedApplication().mainWindow?.beginSheet(self.progressBar!.window!, completionHandler: nil)
            }
        })
        
        let task = tool.installIfNeeded { (success) -> () in
            var reducedArray = Array<Dependency>(dependencies)
            reducedArray.removeAtIndex(0)
            println("Installed \(tool.name), \(reducedArray.count) dependencies left")
            if success && reducedArray.count > 0 {
                println("Proceeding to next dependency")
                self.progressBar?.progressIndicator.doubleValue = Double(totalCount - reducedArray.count) / Double(totalCount)
                self.installDependeniesInOrder(reducedArray, totalCount: totalCount, completion: completion)
            } else {
                println("Done installing dependencies with success? \(success) still missing: \(reducedArray.count)")
                if let progressBar = self.progressBar {
                    if success {
                        progressBar.progressIndicator.doubleValue = 1
                        progressBar.label.stringValue = "Success!"
                    } else {
                        progressBar.label.stringValue = "Error installing \(tool.name). Aborting."
                    }
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                        Int64(0.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        progressBar.window!.orderOut(nil)
                        NSApplication.sharedApplication().mainWindow?.endSheet(progressBar.window!)
                        self.progressBar = nil
                        completion(success: success)
                    }
                } else {
                    completion(success: success)
                }
            }
        }
        self.delegate?.startingTask(task)
    }
    
    func initializedToolForDependency(dependency: Dependency) -> CLITool {
        switch dependency {
        case .Node:
            return Node()
        case .NPM:
            return NPM()
        case .Bower:
            return Bower()
        case .Ember:
            return EmberCLI()
        case .PhantomJS:
            return PhantomJS()
        }
    }
}
