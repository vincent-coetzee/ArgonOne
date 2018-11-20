//
//  SectionTreeViewEntry.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class SectionTreeEntryView: NSTableRowView
    {
    @IBOutlet weak var label:NSTextField!
    @IBOutlet weak var iconImage:NSImageView!
    @IBOutlet weak var trailingConstraint:NSLayoutConstraint!
    
    public var displayItem:DisplayItem = DisplayWrapper()
        {
        didSet
            {
            self.label.stringValue = displayItem.name
            self.iconImage.image = displayItem.iconImage
            }
        }
    
    public override func drawSelection(in dirtyRect:NSRect)
        {
        let insetRect = self.bounds.insetBy(dx: 2, dy:  2)
        NSColor.argonPink.setStroke()
        NSColor.argonPink.setFill()
        let path = NSBezierPath(rect: insetRect)
        path.fill()
        path.stroke()
        }
    }
