//
//  ArgonElementCellView.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class ArgonElementCellView: NSTableCellView
    {
    @IBOutlet weak var sizeField:NSTextField!
    @IBOutlet weak var traitsCountField:NSTextField!
    @IBOutlet weak var methodsCountField:NSTextField!
    
    public var labelText:String = ""
        {
        didSet
            {
            textField!.stringValue = labelText
            }
        }
    
    public var iconImage:NSImage = NSImage()
        {
        didSet
            {
            imageView!.image = iconImage
            }
        }

    @IBAction func onRunClicked(_ sender:Any?)
        {
        
        }
    }
