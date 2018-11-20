//
//  SlotAccessNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSlotAssignmentNode:ArgonMethodStatementNode
    {
    public private(set) var slot:ArgonSlotNode
    public private(set) var value:ArgonExpressionNode
    public private(set) var source:ArgonExpressionNode
    public private(set) var _traits:ArgonTraitsNode
    
    init(slot:ArgonSlotNode,of source:ArgonExpressionNode,value:ArgonExpressionNode,traits:ArgonTraitsNode)
        {
        self.slot = slot
        self.value = value
        self.source = source
        _traits = traits
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        var sourceAddress:ThreeAddress
        if source is ThreeAddress
            {
            sourceAddress = source as! ThreeAddress
            }
        else
            {
            try source.threeAddress(pass: pass)
            sourceAddress = pass.lastLHS()
            }
        var valueAddress:ThreeAddress
        if value is ThreeAddress
            {
            valueAddress = value as! ThreeAddress
            }
        else
            {
            try value.threeAddress(pass: pass)
            valueAddress = pass.lastLHS()
            }
        let slotLayout = source.traits.slotLayout(forSlotNamed: slot.name)
        let temp = pass.newTemporary()
        pass.add(ThreeAddressInstruction(lhs: temp, operand1: ThreeAddressPointer(to: sourceAddress), operation: .add, operand2: slotLayout!.offsetInInstance))
        pass.add(ThreeAddressInstruction(lhs: ThreeAddressContentsOfPointer(ThreeAddressPointer(in: temp)), operation: .assign,operand1: valueAddress))
        }
    }
