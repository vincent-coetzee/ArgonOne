//
//  ArgonHandlerStatement.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonHandlerStatementNode:ArgonCompoundMethodStatementNode,ArgonCodeContainer,ThreeAddress
    {
    public var isVariable:Bool
        {
        return(false)
        }
    
    public var isParameter:Bool
        {
        return(false)
        }
    
    public var isConstant: Bool
        {
        return(false)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isStackBased: Bool
        {
        return(false)
        }
    
    public var locations = ArgonValueLocationList()
    public var name: ArgonName = ArgonName()
    public private(set) var id: Int
    public var instructionList: VMInstructionList
    public var threeAddressInstructions:[ThreeAddressInstruction] = []
    public private(set) var conditionSymbol:String = ""
    
    public var lastLHS:ThreeAddress
        {
        return(threeAddressInstructions.last!.lhs!)
        }
    
    public func asArgonHandler() -> ArgonHandler
        {
        let fullName = containingScope.enclosingModule().moduleName.string + ".HANDLER(\(id))"
        let new = ArgonHandler(fullName: fullName,code: ArgonCodeBlock(instructionList))
        new.id = id
        new.conditionSymbol = conditionSymbol
        return(new)
        }
        
    public init(containingScope:ArgonParseScope,conditionSymbol:String)
        {
        self.instructionList = VMInstructionList()
        self.id = Argon.nextCounter
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
    
    public func isSame(as other: ThreeAddress) -> Bool
        {
        if type(of:self) == type(of:other)
            {
            let rhs = other as! ArgonHandlerStatementNode
            if rhs.id == self.id
                {
                return(true)
                }
            }
        return(false)
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .jump,target: label))
        pass.add(ThreeAddressInstruction(operation: .handler,operand1: self))
        try self.statements.threeAddress(pass: pass)
        pass.labelNextInstruction(with: label)
        }
    }

