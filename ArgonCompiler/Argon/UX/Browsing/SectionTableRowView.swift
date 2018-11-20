//
//  SectionTableRowView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class SectionTableRowView: NSTableRowView
    {
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
