//
//  ArgonComparisonExpressionNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/13.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonRelationExpressionNode:ArgonArithmeticExpressionNode
    {
    public override var traits:ArgonTraitsNode
        {
        if lhs.traits == rhs.traits
            {
            return(ArgonStandardsNode.shared.booleanTraits)
            }
        return(ArgonStandardsNode.shared.errorTraits)
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var address1:ThreeAddress
        if lhs is ThreeAddress
            {
            address1 = lhs as! ThreeAddress
            }
        else
            {
            try lhs.threeAddress(pass: pass)
            address1 = pass.lastLHS()
            }
        var address2:ThreeAddress
        if rhs is ThreeAddress
            {
            address2 = rhs as! ThreeAddress
            }
        else
            {
            try rhs.threeAddress(pass: pass)
            address2 = pass.lastLHS()
            }
        var threeAddressOperation:ThreeAddressOperation
        switch(operation)
            {
            case .leftBro:
                threeAddressOperation = .lt
            case .lessThanEqual:
                threeAddressOperation = .lte
            case .equal:
                threeAddressOperation = .eq
            case .greaterThanEqual:
                threeAddressOperation = .gte
            case .rightBro:
                threeAddressOperation = .gt
            default:
                threeAddressOperation = .none
            }
        pass.add(ThreeAddressInstruction(lhs:pass.newTemporary(),operand1: address1,operation:threeAddressOperation,operand2:address2))
        }
    }
