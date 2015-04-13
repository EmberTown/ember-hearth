//
//  OpenDialogExtentions.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 13.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

extension NSOpenPanel {
    class func hearthFolderPicker(projectName: String?, allowFolderCreation: Bool) -> NSOpenPanel {
        var panel = NSOpenPanel()
        if let name = projectName {
            panel.message = "Select a location for the project folder (the folder \"\(name)\" will be created)"
        }
        panel.maxSize = CGSize(width: 500.0, height: 500.0)
        panel.canCreateDirectories = allowFolderCreation
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        return panel
    }
}
