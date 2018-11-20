//
//  ListViewCell.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class ListViewCell: NSTableCellView
    {
    @IBOutlet var labelField:NSTextField!
    
    public var stringValue:String = ""
        {
        didSet
            {
            labelField.stringValue = stringValue
            labelField.font = NSFont(name:"Menlo-Bold",size: 12)!
            }
        }
    
    public var attributedStringValue:NSAttributedString = NSAttributedString(string:"",attributes:[:])
        {
        didSet
            {
            labelField.stringValue = stringValue
            labelField.font = NSFont(name:"Menlo-Bold",size: 12)!
            }
        }
    }
