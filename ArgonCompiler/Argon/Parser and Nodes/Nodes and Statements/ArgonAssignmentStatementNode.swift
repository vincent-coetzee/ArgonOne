//
//  ArgonAssignmentStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonAssignmentStatementNode:ArgonMethodStatementNode
    {
    public let lValue:ArgonStoredValueNode
    public let rValue:ArgonExpressionNode
    
    init(target:ArgonStoredValueNode,source:ArgonExpressionNode)
        {
        lValue = target
        rValue = source
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var address:ThreeAddress
        if rValue is ThreeAddress
            {
            address = rValue as! ThreeAddress
            }
        else
            {
            try rValue.threeAddress(pass: pass)
            address = pass.lastLHS()
            }
        pass.add(ThreeAddressInstruction(lhs: lValue,operand1: address,operation: .assign,operand2:nil))
        }
        
    public func threeAddress(pass:ThreeAddressPass) throws -> [ThreeAddressInstruction]
        {
        fatalError("This should not be called")
        }
    }
