//
//  SlotDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class SlotDisplayWrapper:DisplayWrapper
    {
    private let slot:ArgonSlotNode
    
    public override var name:String
        {
        return(slot.name.string)
        }
    
    public override var traitsName:String
        {
        return(slot.traits.name.string)
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Slot")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.slot)
        }
    
    init(slot:ArgonSlotNode)
        {
        self.slot = slot
        }
    
    public override var nakedItem:Any?
        {
        return(slot)
        }
    
    public override func render(column:NSTableColumn) -> NSView?
        {
        if column.identifier.rawValue == "0"
            {
            let view = NSImageView(frame: .zero)
            view.image = self.iconImage
            return(view)
            }
        else if column.identifier.rawValue == "1"
            {
            let view = NSTextField(labelWithString: self.name)
            return(view)
            }
        else if column.identifier.rawValue == "2"
            {
            let view = CartoucheView(frame: .zero)
            view.text = slot.traits.name.string
            return(view)
            }
        return(nil)
        }
    }
