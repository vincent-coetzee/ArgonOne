//
//  ListViewCell.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class SlotCellView: NSTableCellView
    {
    @IBOutlet var labelField:NSTextField!
    @IBOutlet var valueField:NSTextField!
    
    public var label:String = ""
        {
        didSet
            {
            labelField.stringValue = label
            }
        }
    
    public var value:String = ""
        {
        didSet
            {
            valueField.stringValue = value
            }
        }
    }
