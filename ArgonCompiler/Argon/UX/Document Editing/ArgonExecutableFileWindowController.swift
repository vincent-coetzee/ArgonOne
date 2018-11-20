//
//  ArgonExecutableFileWindowController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class ArgonExecutableFileWindowController: NSWindowController {

    public var executableFileViewController:ArgonExecutableFileViewController
        {
        return(self.contentViewController as! ArgonExecutableFileViewController)
        }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
