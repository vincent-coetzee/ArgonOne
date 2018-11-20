//
//  ArgonExecutableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonExecutableNode:ArgonTopLevelNode,ArgonCodeContainer
    {
    public var entryPoint:ArgonEntryPointNode?
    private var threeAddressInstructions:[ThreeAddressInstruction] = []
    public var instructionList = VMInstructionList()
    
    public private(set) var id:Int
    
    public var allGenericMethods:[ArgonGenericMethodNode]
        {
        return(nodes.filter{$0 is ArgonGenericMethodNode}.map{$0 as! ArgonGenericMethodNode})
        }
    
    public var allNamedConstants:[ArgonNamedConstantNode]
        {
        return(nodes.filter{$0 is ArgonNamedConstantNode}.map{$0 as! ArgonNamedConstantNode})
        }
    
    public var allTraits:[ArgonTraitsNode]
        {
        return(nodes.filter{$0 is ArgonTraitsNode}.map{$0 as! ArgonTraitsNode})
        }
    
    public var lastLHS: ThreeAddress
        {
        return(threeAddressInstructions.last!.lhs!)
        }
    
    public override init(name:ArgonName)
        {
        id = Argon.nextCounter
        super.init(name:name)
        }
    
    public func asArgonExecutable() -> ArgonExecutable
        {
        let new = ArgonExecutable(fullName: self.name.string)
        new.executableInit = ArgonCodeBlock(instructionList)
        new.entryPoint = ArgonCodeBlock(entryPoint!.instructionList)
        return(new)
        }
    
    public func add(_ instruction: ThreeAddressInstruction) -> Int
        {
        let offset = threeAddressInstructions.count
        threeAddressInstructions.append(instruction)
        return(offset)
        }
    
    public func generateCode(with generator:ThreeAddressCodeGenerator) throws
        {
        print("Generating code for executable")
        try generator.generateCode(from: threeAddressInstructions,in: self)
        }
    
    public func dump()
        {
        print("DUMPING EXECUTABLE")
        instructionList.dump()
        }
        
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        pass.setTopLevelContainer(self)
        pass.pushContainer(self)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: locals.count*8,comment: "// Executable",stackFrameNumber:enclosingStackFrame!.number))
        try super.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(operation: .leave,operand1: locals.count*8,comment: "// Executable"))
        self.add(ThreeAddressInstruction(operation: .ret))
        pass.popContainer()
        }
    }
