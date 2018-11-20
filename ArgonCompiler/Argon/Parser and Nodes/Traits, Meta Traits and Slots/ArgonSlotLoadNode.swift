//
//  ArgonSlotLoadNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonSlotLoadNode:ArgonExpressionNode
    {
    public private(set) var slot:ArgonSlotNode
    public private(set) var instanceExpression:ArgonExpressionNode?
    public private(set) var _traits:ArgonTraitsNode

    public override var traits:ArgonTraitsNode
        {
        return(slot.traits)
        }

    init(slot:ArgonSlotNode,instance:ArgonExpressionNode?,traits:ArgonTraitsNode)
        {
        self.slot = slot
        self.instanceExpression = instance
        self._traits = traits
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        var instanceAddress:ThreeAddress
        if instanceExpression is ThreeAddress
            {
            instanceAddress = instanceExpression as! ThreeAddress
            }
        else
            {
            try instanceExpression?.threeAddress(pass: pass)
            instanceAddress = pass.lastLHS()
            }
        let slotLayout = _traits.slotLayout(forSlotNamed: slot.name)
        let temp = pass.newTemporary()
        pass.add(ThreeAddressInstruction(lhs: temp, operand1: ThreeAddressPointer(to: instanceAddress), operation: .add, operand2: slotLayout!.offsetInInstance))
        pass.add(ThreeAddressInstruction(lhs: pass.newTemporary(), operation: .assign,operand1: ThreeAddressContentsOfPointer(ThreeAddressPointer(in: temp))))
        }
    }
