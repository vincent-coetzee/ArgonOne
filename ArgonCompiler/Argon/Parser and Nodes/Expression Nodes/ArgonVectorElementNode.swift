//
//  CollectionElementGetterNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonVectorElementNode:ArgonExpressionNode
    {
    public private(set) var collection:ArgonExpressionNode
    public private(set) var index:ArgonExpressionNode
    
    // FIXME - Should return the trait assigned to the Vector from it's first assignment
    public override var traits:ArgonTraitsNode
        {
        return(ArgonStandardsNode.shared.anyTraits)
        }
    
    init(vector:ArgonExpressionNode,index:ArgonExpressionNode)
        {
        self.collection = vector
        self.index = index
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var address1:ThreeAddress
        if collection is ThreeAddress
            {
            address1 = collection as! ThreeAddress
            }
        else
            {
            try collection.threeAddress(pass: pass)
            address1 = pass.lastLHS()
            }
        var address2:ThreeAddress
        if index is ThreeAddress
            {
            address2 = index as! ThreeAddress
            }
        else
            {
            try index.threeAddress(pass: pass)
            address2 = pass.lastLHS()
            }
        let temp = pass.newTemporary()
        let indexTemp = pass.newTemporary()
        pass.add(ThreeAddressInstruction(lhs: indexTemp,operand1: address2, operation: .mul, operand2: 8))
        pass.add(ThreeAddressInstruction(lhs: temp,operand1: ThreeAddressPointer(to: address1), operation: .add, operand2: indexTemp))
        pass.add(ThreeAddressInstruction(lhs: pass.newTemporary(),operation: .assign, operand1: ThreeAddressContentsOfPointer(ThreeAddressPointer(in: temp))))
        }
    }
