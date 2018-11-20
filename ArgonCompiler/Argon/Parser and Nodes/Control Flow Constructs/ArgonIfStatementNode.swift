//
//  ArgonIfNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonIfStatementNode:ArgonCompoundMethodStatementNode
    {
    private var condition:ArgonExpressionNode
    public var elseClause:ArgonElseClauseNode?
    
    init(containingScope:ArgonParseScope,condition:ArgonExpressionNode)
        {
        self.condition = condition
        super.init(containingScope:containingScope)
        }

    public override func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + "if\(enclosingStackFrame!.number)")
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var offset = -8
        for local in locals
            {
            local.offsetFromBP = offset
            offset -= 8
            }
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: self.locals.count * 8,comment:"// If statement",stackFrameNumber:enclosingStackFrame!.number))
        let label = pass.newLabel()
        try condition.threeAddress(pass:pass)
        pass.add(ThreeAddressInstruction(operand1:pass.lastLHS(),operation: .jumpIfFalse,target: label))
        try statements.threeAddress(pass: pass)
        if elseClause != nil && elseClause!.statements.count > 0
            {
            pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
            let outLabel = pass.newLabel()
            pass.add(ThreeAddressInstruction(operation: .jump,target: outLabel))
            pass.labelNextInstruction(with: label)
            try elseClause!.statements.threeAddress(pass: pass)
            pass.labelNextInstruction(with: outLabel)
            }
        else
            {
            pass.labelNextInstruction(with: label)
            }
         pass.add(ThreeAddressInstruction(operation: .leave,operand1: self.locals.count * 8))
        }
    }
