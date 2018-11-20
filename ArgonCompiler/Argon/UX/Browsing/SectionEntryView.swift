//
//  ArgonSectionEntryView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class SectionEntryView: NSView
    {
    @IBOutlet weak var label:NSTextField!
    @IBOutlet weak var iconImage:NSImageView!

    public var displayItem:DisplayItem = DisplayWrapper()
        {
        didSet
            {
            self.label.stringValue = displayItem.name
            self.iconImage.image = displayItem.iconImage
            }
        }
    }

