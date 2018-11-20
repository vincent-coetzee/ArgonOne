//
//  ArgonExecutableFileViewController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class ArgonExecutableFileViewController: NSViewController
    {
    var document:ArgonExecutableFile?
        {
        didSet
            {
            update(from: document!)
            }
        }
    
    private func update(from: ArgonExecutableFile)
        {
        }
        
    override func viewDidLoad()
        {
        super.viewDidLoad()
        // Do view setup here.
        }
    }
