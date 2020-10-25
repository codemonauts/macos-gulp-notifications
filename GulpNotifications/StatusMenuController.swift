//
//  StatusMenuController.swift
//  GulpNotifications
//
//  Created by Thomas Schulze on 08.10.17.
//  Copyright © 2017 codemonauts UG (haftungsbeschränkt). All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {

    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

}
