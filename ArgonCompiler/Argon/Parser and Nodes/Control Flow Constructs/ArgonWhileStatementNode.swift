//
//  ArgonWhileStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonWhileStatementNode:ArgonCompoundMethodStatementNode
    {
    public private(set) var condition:ArgonExpressionNode
    
    init(containingScope:ArgonParseScope,condition:ArgonExpressionNode)
        {
        self.condition = condition
        super.init(containingScope:containingScope)
        }

    public override func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + "while\(enclosingStackFrame!.number)")
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
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: self.locals.count * 8,comment: "// While statement",stackFrameNumber:enclosingStackFrame!.number))
        let loopLabel = pass.newLabel()
        let outLabel = pass.newLabel()
        pass.labelNextInstruction(with: loopLabel)
        try condition.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(operand1:pass.lastLHS(),operation: .jumpIfFalse,target: outLabel))
        try statements.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(operation: .jump,target: loopLabel))
        pass.labelNextInstruction(with: outLabel)
         pass.add(ThreeAddressInstruction(operation: .leave,operand1: self.locals.count * 8))
        }
    }
