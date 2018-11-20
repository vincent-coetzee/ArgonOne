//
//  ViewController.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class AssemblyViewController: NSViewController
    {
    @IBOutlet weak var sourceField:NSTextView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        }
    
    @IBAction func openDocument(_ sender:Any?)
        {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.worksWhenModal = true
        openPanel.allowedFileTypes = ["arasm"]
        openPanel.beginSheetModal(for: self.view.window!)
            {
            response in
            if response == NSApplication.ModalResponse.OK
                {
                }
            }
        }
    
    @IBAction func onAssembleClicked(_ sender:Any?)
        {
        }
    }

