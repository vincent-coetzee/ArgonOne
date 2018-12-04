//
//  ArgonSystemTraitsNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSystemSlotNode:ArgonSlotNode
    {
    public var fixedOffset:Int = 0
    }

public class ArgonSystemTraitsNode:ArgonTraitsNode
    {
    private var systemSlots = ArgonSlotList()
    
    public override var firstSlotOffset:Int
        {
        return(24 + systemSlots.count * Int(ArgonWordSize));
        }
    
    public override func resolve(name:ArgonName) -> ArgonParseNode?
        {
        if let scope = containingScope,let method = scope.enclosingMethod(),method.hasSystemDirective
            {
            return(super.resolve(name:name))
            }
        for slot in systemSlots
            {
            if slot.name == name
                {
                return(slot)
                }
            }
        return(super.resolve(name:name))
        }
    
    public func addSystemSlot(name:String,offset:Int,traits:ArgonTraitsNode)
        {
        let node = ArgonSystemSlotNode(name: name, type: traits)
        node.fixedOffset = offset
        systemSlots.append(node)
        }
    }
