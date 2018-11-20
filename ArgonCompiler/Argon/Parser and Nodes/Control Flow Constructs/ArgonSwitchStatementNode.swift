//
//  ArgonSwitchStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSwitchStatementNode:ArgonCompoundMethodStatementNode
    {
    public var switchExpression:ArgonExpressionNode
    public var cases:[ArgonCaseStatementNode] = []
    public var otherwise:ArgonCompoundMethodStatementNode?
    
    init(containingScope:ArgonParseScope,expression:ArgonExpressionNode)
        {
        switchExpression = expression
        super.init(containingScope: containingScope)
        }
    
    public override func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + "switch\(enclosingStackFrame!.number)")
        }
    
    public func add(case aCase:ArgonCaseStatementNode)
        {
        cases.append(aCase)
        }
    
    public func add(otherwise:ArgonCompoundMethodStatementNode)
        {
        self.otherwise = otherwise
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        var offset = -8
        for local in locals
            {
            local.offsetFromBP = offset
            offset -= 8
            }
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: self.locals.count * 8,comment: "// Switch statement",stackFrameNumber:enclosingStackFrame!.number))
        let outLabel = pass.newLabel()
        for aCase in cases
            {
            aCase.label = pass.newLabel()
            }
        otherwise?.label = pass.newLabel()
        var switchValue:ThreeAddress
        if switchExpression is ThreeAddress
            {
            switchValue = switchExpression as! ThreeAddress
            }
        else
            {
            try switchExpression.threeAddress(pass: pass)
            switchValue = pass.lastLHS()
            }
        for index in 0..<cases.count
            {
            let aCase = cases[index]
            if index != 0
                {
                pass.labelNextInstruction(with: aCase.label)
                }
            var caseAddress:ThreeAddress
            pass.addLineTraceToNextStatement(lineTrace: aCase.lineTrace!)
            if aCase.caseExpression is ThreeAddress
                {
                caseAddress = aCase.caseExpression as! ThreeAddress
                }
            else
                {
                try aCase.caseExpression.threeAddress(pass: pass)
                caseAddress = pass.lastLHS()
                }
            if index < cases.count - 1
                {
                let caseTemp = pass.newTemporary()
                pass.add(ThreeAddressInstruction(lhs: caseTemp,operand1: caseAddress,operation: .eq,operand2: switchValue))
                pass.add(ThreeAddressInstruction(operand1: caseTemp,operation: .jumpIfFalse,target: cases[index+1].label)) 
                }
            else if index == cases.count - 1
                {
                let caseTemp = pass.newTemporary()
                pass.add(ThreeAddressInstruction(lhs: caseTemp,operand1: caseAddress,operation: .eq,operand2: switchValue))
                if otherwise == nil
                    {
                    pass.add(ThreeAddressInstruction(operand1: caseTemp,operation: .jumpIfFalse,target: outLabel))
                    }
                else
                    {
                    pass.add(ThreeAddressInstruction(operand1: caseTemp,operation: .jumpIfFalse,target: otherwise!.label))
                    }
                }
            try aCase.threeAddress(pass: pass)
            pass.add(ThreeAddressInstruction(operation: .jump,target: outLabel))
            }
        if otherwise != nil
            {
            pass.addLineTraceToNextStatement(lineTrace: otherwise!.lineTrace!)
            pass.labelNextInstruction(with: otherwise!.label)
            if otherwise!.statements.count == 0
                {
                pass.add(ThreeAddressInstruction())
                }
            else
                {
                try otherwise!.threeAddress(pass: pass)
                }
            }
        pass.labelNextInstruction(with: outLabel)
        pass.add(ThreeAddressInstruction(operation: .leave,operand1: self.locals.count * 8))
        }
    }
