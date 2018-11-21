//
//  ArgonHandlerStatement.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonHandlerStatementNode:ArgonCompoundMethodStatementNode,ArgonCodeContainer
    {
    public private(set) var id: Int
    public var instructionList: VMInstructionList
    public var threeAddressInstructions:[ThreeAddressInstruction] = []
    public private(set) var conditionNode:ArgonInductionVariableNode
    public private(set) var conditionSymbol:ArgonExpressionNode
    
    public var lastLHS:ThreeAddress
        {
        return(threeAddressInstructions.last!.lhs!)
        }
    
    public init(containingScope:ArgonParseScope,conditionNode:ArgonInductionVariableNode,conditionSymbol:ArgonExpressionNode)
        {
        self.instructionList = VMInstructionList()
        self.id = Argon.nextCounter
        self.conditionNode = conditionNode
        self.conditionSymbol = conditionSymbol
        super.init(containingScope:containingScope)
        }
    
    public func add(_ instruction: ThreeAddressInstruction) -> Int
        {
        let offset = threeAddressInstructions.count
        threeAddressInstructions.append(instruction)
        return(offset)
        }
    
    public func generateCode(with generator: ThreeAddressCodeGenerator) throws
        {
        try generator.generateCode(from: threeAddressInstructions, in: self)
        }
    
    public func dump()
        {
        instructionList.dump()
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        var address:ThreeAddress
        if conditionSymbol is ThreeAddress
            {
            address = conditionSymbol as! ThreeAddress
            }
        else
            {
            try conditionSymbol.threeAddress(pass: pass)
            address = pass.lastLHS()
            }
        let label = pass.newLabel()
        pass.add(ThreeAddressInstruction(operation: .jump,target: label))
        pass.add(ThreeAddressInstruction(operation: .handler,operand1: conditionNode,operand2: address))
        try self.statements.threeAddress(pass: pass)
        pass.labelNextInstruction(with: label)
        }
    }

