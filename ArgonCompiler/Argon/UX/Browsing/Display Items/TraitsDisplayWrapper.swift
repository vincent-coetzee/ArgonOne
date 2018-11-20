//
//  TraitsDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class TraitsDisplayWrapper:DisplayWrapper
    {
    private let traits:ArgonTraitsNode
    private var list = DisplayItemList()
    
    public override var name:String
        {
        return(traits.name.string)
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Traits")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.traits)
        }
    
    public override var children:DisplayItemList
        {
        guard list.isEmpty else
            {
            return(list)
            }
        list = DisplayItemList(items: traits.totalSlots().map {SlotDisplayWrapper(slot: $0)})
        return(list)
        }
    
    init(traits:ArgonTraitsNode)
        {
        self.traits = traits
        }
    }
