//
//  ArgonEntryPointNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonEntryPointNode:ArgonCompoundMethodStatementNode,ArgonCodeContainer
    {
    private var entryPoint:ArgonEntryPointNode?
    private var threeAddressInstructions:[ThreeAddressInstruction] = []
    public var instructionList = VMInstructionList()
    
    public private(set) var id:Int
    
    public var lastLHS: ThreeAddress
        {
        return(threeAddressInstructions.last!.lhs!)
        }
    
    public override init(containingScope:ArgonParseScope)
        {
        id = Argon.nextCounter
        super.init(containingScope:containingScope)
        }
    
    public func add(_ instruction: ThreeAddressInstruction) -> Int
        {
        let offset = threeAddressInstructions.count
        threeAddressInstructions.append(instruction)
        return(offset)
        }
        
    public func generateCode(with generator:ThreeAddressCodeGenerator) throws
        {
        print("Generating code for entry point")
        generator.reset()
        try generator.generateCode(from: threeAddressInstructions,in:self)
        }
    
    public func dump()
        {
        print("DUMPING ENTRYPOINT")
        instructionList.dump()
        }
    public override func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + "entrypoint")
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.pushContainer(self)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: locals.count*8,comment: "// Entrypoint",stackFrameNumber:enclosingStackFrame!.number))
        try super.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(operation: .leave,operand1: locals.count*8,comment: "// Leave Entrypoint"))
        pass.add(ThreeAddressInstruction(operation: .ret))
        pass.popContainer()
        }
    }
