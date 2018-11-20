//
//  ArgonVectorElementAssignmentNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/23.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonVectorElementAssignmentNode:ArgonMethodStatementNode
    {
    public private(set) var indexExpression:ArgonExpressionNode
    public private(set) var vectorExpression:ArgonExpressionNode
    public private(set) var valueExpression:ArgonExpressionNode
    
    public init(vector:ArgonExpressionNode,index:ArgonExpressionNode,value:ArgonExpressionNode)
        {
        indexExpression = index
        vectorExpression = vector
        valueExpression = value
        super.init()
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var vectorAddress:ThreeAddress
        if vectorExpression is ThreeAddress
            {
            vectorAddress = vectorExpression as! ThreeAddress
            }
        else
            {
            try vectorExpression.threeAddress(pass: pass)
            vectorAddress = pass.lastLHS()
            }
        var indexAddress:ThreeAddress
        if indexExpression is ThreeAddress
            {
            indexAddress = indexExpression as! ThreeAddress
            }
        else
            {
            try indexExpression.threeAddress(pass: pass)
            indexAddress = pass.lastLHS()
            }
        var valueAddress:ThreeAddress
        if valueExpression is ThreeAddress
            {
            valueAddress = valueExpression as! ThreeAddress
            }
        else
            {
            try valueExpression.threeAddress(pass: pass)
            valueAddress = pass.lastLHS()
            }
        let indexTemp = pass.newTemporary()
        pass.add(ThreeAddressInstruction(lhs: indexTemp,operand1: indexAddress, operation: .add, operand2: ThreeAddressPointer(to: vectorAddress)))
        pass.add(ThreeAddressInstruction(lhs: ThreeAddressContentsOfPointer(ThreeAddressPointer(in: indexTemp)),operation: .assign,operand1: valueAddress))
        }
    }
