//
//  ArgonSourceFileWindowController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class ArgonSourceFileWindowController: NSWindowController
    {
    public var sourceFileViewController:ArgonSourceFileViewController
        {
        return(self.contentViewController as! ArgonSourceFileViewController)
        }
    
    override func windowDidLoad()
        {
        super.windowDidLoad()
        }
    }
