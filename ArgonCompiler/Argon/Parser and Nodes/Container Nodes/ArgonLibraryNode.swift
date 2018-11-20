//
//  ArgonLibraryNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonLibraryNode:ArgonTopLevelNode,ArgonCodeContainer
    {
    private var threeAddressInstructions:[ThreeAddressInstruction] = []
    public var instructionList:VMInstructionList = VMInstructionList()
    
    public private(set) var id:Int
    
    public var isLibrary:Bool
        {
        return(true)
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
    
    public func add(_ instruction: ThreeAddressInstruction) -> Int
        {
        let offset = threeAddressInstructions.count
        threeAddressInstructions.append(instruction)
        return(offset)
        }
    
    public func generateCode(with generator:ThreeAddressCodeGenerator) throws
        {
        try generator.generateCode(from: threeAddressInstructions,in:self)
        }
    
    public func dump()
        {
        instructionList.dump()
        }
    
    public func asArgonLibrary() -> ArgonLibrary
        {
        let new = ArgonLibrary(fullName: self.name.string)
        let exportNodes = nodes.filter{$0 is ArgonExportNode}.map {($0 as! ArgonExportNode).asArgonExport()}
        var exports:[String:ArgonExport] = [:]
        for export in exportNodes
            {
            exports[export.name] = export
            }
        for node in nodes.filter({$0 is ArgonImportNode}).map({($0 as! ArgonImportNode).asArgonImport()})
            {
            }
        new.libraryInit = ArgonCodeBlock(instructionList)
        let methodNodes = nodes.filter{$0.isGenericMethod}
        new.genericMethods = methodNodes.map{($0 as! ArgonGenericMethodNode).asArgonGenericMethod()}
        new.constants = nodes.filter{$0.isNamedConstant}.map{($0 as! ArgonNamedConstantNode).asArgonNamedConstant()}
        new.globals = globals.map{$0.asArgonGlobal()}
        return(new)
        }
    //
    // TODO:
    // How are libraries going to implement thier locals when they do not have access
    // to the local stack.
    //
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.setTopLevelContainer(self)
        pass.pushContainer(self)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: locals.count*8,comment: "// Library",stackFrameNumber:enclosingStackFrame!.number))
        var offset = 16
        for local in locals
            {
            local.offsetFromBP = offset
            try local.threeAddress(pass: pass)
            offset += 8
            }
        for constant in constants
            {
            try constant.threeAddress(pass: pass)
            }
        for node in nodes
            {
            try node.threeAddress(pass: pass)
            }
        pass.add(ThreeAddressInstruction(operation: .leave,operand1: locals.count*8,comment: "// Leave Library"))
        pass.popContainer()
        }
    }
