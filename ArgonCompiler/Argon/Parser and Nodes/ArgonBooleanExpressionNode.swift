//
//  ArgonBooleanExpressionNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonBooleanExpressionNode:ArgonArithmeticExpressionNode
    {
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
        if operation == .and
            {
            let temp = pass.newTemporary()
            let falseLabel = pass.newLabel()
            let outLabel = pass.newLabel()
            pass.add(ThreeAddressInstruction(operand1: address1,operation: .jumpIfFalse,target: falseLabel))
            pass.add(ThreeAddressInstruction(operand1: address2,operation: .jumpIfFalse,target: falseLabel))
            pass.add(ThreeAddressInstruction(lhs: temp,operation: .assign,operand1: 1))
            pass.add(ThreeAddressInstruction(operation: .jump,target: outLabel))
            let instruction = ThreeAddressInstruction(lhs: temp,operation: .assign,operand1: 0)
            instruction.label = falseLabel
            pass.add(instruction)
            pass.labelNextInstruction(with: outLabel)
            }
        else
            {
            let temp = pass.newTemporary()
            let trueLabel = pass.newLabel()
            let outLabel = pass.newLabel()
            pass.add(ThreeAddressInstruction(operand1: address1,operation: .jumpIfTrue,target: trueLabel))
            pass.add(ThreeAddressInstruction(operand1: address2,operation: .jumpIfTrue,target: trueLabel))
            pass.add(ThreeAddressInstruction(lhs: temp,operation: .assign,operand1: 0))
            pass.add(ThreeAddressInstruction(operation: .jump, target: outLabel))
            let instruction = ThreeAddressInstruction(lhs: temp,operation: .assign,operand1: 1)
            instruction.label = trueLabel
            pass.add(instruction)
            pass.labelNextInstruction(with: outLabel)
            }
        }
    }
