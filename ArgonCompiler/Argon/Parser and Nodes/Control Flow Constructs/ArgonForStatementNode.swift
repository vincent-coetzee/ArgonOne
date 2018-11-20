//
//  ArgonLoopNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

//
//
// for variable in (from fromValue,to toValue[,step stepValue])
//
//
public class ArgonForStatementNode:ArgonCompoundMethodStatementNode
    {
    public var lowerBound:ArgonExpressionNode?
    public var upperBound:ArgonExpressionNode?
    public var step:ArgonExpressionNode?
    public var iterable:ArgonNamedNode?
    public var resultType:ArgonNamedNode!
    public var inductionVariable:ArgonInductionVariableNode?
    
    public func lowerBound(_ lower:ArgonExpressionNode,upperBound:ArgonExpressionNode,step:ArgonExpressionNode)
        {
        lowerBound = lower
        self.upperBound = upperBound
        self.step = step
        }
    
    public func setIterable(_ iterable:ArgonNamedNode)
        {
        self.iterable = iterable
        }

    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: self.locals.count * 8,comment:"// For statement",stackFrameNumber:enclosingStackFrame!.number))
        var lowerAddress:ThreeAddress
        if lowerBound! is ThreeAddress
            {
            lowerAddress = lowerBound as! ThreeAddress
            }
        else
            {
            try lowerBound!.threeAddress(pass: pass)
            lowerAddress = pass.lastLHS()
            }
        var upperAddress:ThreeAddress
        if upperBound! is ThreeAddress
            {
            upperAddress = upperBound as! ThreeAddress
            }
        else
            {
            try upperBound!.threeAddress(pass: pass)
            upperAddress = pass.lastLHS()
            }
        var stepAddress:ThreeAddress
        if step! is ThreeAddress
            {
            stepAddress = step as! ThreeAddress
            }
        else
            {
            try step!.threeAddress(pass: pass)
            stepAddress = pass.lastLHS()
            }
        pass.add(ThreeAddressInstruction(lhs:inductionVariable!,operand1: lowerAddress,operation: .assign,operand2: nil))
        let loopLabel = pass.newLabel()
        pass.labelNextInstruction(with: loopLabel)
        try statements.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(lhs:inductionVariable!,operand1:inductionVariable,operation: .add,operand2: stepAddress))
        let temp = pass.newTemporary()
        pass.add(ThreeAddressInstruction(lhs:temp,operand1: inductionVariable!,operation: .lt,operand2: upperAddress))
        pass.add(ThreeAddressInstruction(operand1:temp,operation: .jumpIfTrue,target: loopLabel))
         pass.add(ThreeAddressInstruction(operation: .leave,operand1: self.locals.count * 8))
        }
    
    public override func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + "forLoop\(enclosingStackFrame!.number)")
        }
    }
