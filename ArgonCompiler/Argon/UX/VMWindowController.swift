//
//  VMWindowController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class VMWindowController: NSWindowController {

    public var vmViewController:VMViewController
        {
        return(self.contentViewController as! VMViewController)
        }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
