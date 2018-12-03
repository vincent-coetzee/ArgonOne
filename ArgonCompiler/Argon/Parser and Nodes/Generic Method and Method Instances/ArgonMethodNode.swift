//
//  ArgonMethodNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonMethodNode:ArgonExpressionNode,ArgonParseScope,ThreeAddress,ArgonCodeContainer
    {
    public var directives:ArgonMethodDirective = []
    private var threeAddressInstructions:[ThreeAddressInstruction] = []
    public var instructionList = VMInstructionList()
    public var parameters:[ArgonParameterNode] = []
    public var returnType:ArgonType!
    public var statements = ArgonStatementList()
    public var containingScope:ArgonParseScope?
    public var locals:[ArgonLocalVariableNode] = []
    public var name:ArgonName
    public var scopedName:ArgonName = ArgonName("")
    private var _moduleName:ArgonName = ArgonName("")
    public var enclosingStackFrame:ArgonStackFrame?
    public var constants:[ArgonNamedConstantNode] = []
    public var isPrimitive = false
    public var primitiveNumber:Int = 0
    public private(set) var id:Int
    private var handlers:[ArgonHandlerStatementNode] = []
    
    public var hasSystemDirective:Bool
        {
        return(directives.contains(.system))
        }
    
    public var lastLHS: ThreeAddress
        {
        return(threeAddressInstructions.last!.lhs!)
        }
    
    public func asArgonMethod() -> ArgonMethod
        {
        let new = ArgonMethod(fullName: ArgonName(_moduleName.string,self.name.string).string)
        new.returnType = returnType?.traits.asArgonTraits() ?? ArgonRelocationTable.shared.traits(at: "Argon::Void")!
        new.parameters = self.parameters.map{$0.asArgonParameter()}
        new.moduleName = _moduleName.string
        new.code = ArgonCodeBlock(instructionList)
        new.isPrimitive = isPrimitive
        new.primitiveNumber = primitiveNumber
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
        try generator.generateCode(from: threeAddressInstructions,in:self)
        }
    
    public func dump()
        {
        print("DUMPING METHOD")
        instructionList.dump()
        }
    
    public var moduleName:ArgonName
        {
        get
            {
            return(_moduleName)
            }
        set
            {
            _moduleName = newValue
            self.scopedName = _moduleName + name
            }
        }
    
    public func isSame(as address:ThreeAddress) -> Bool
        {
        if type(of: address) == type(of: self)
            {
            return(address as! ArgonMethodNode == self)
            }
        return(false)
        }
    
    public var isOperatorBased:Bool
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
    
    public override var isMethod:Bool
        {
        return(true)
        }
    
    public var isVariable:Bool
        {
        return(false)
        }
        
    public var isPrimitiveMethod:Bool
        {
        return(false)
        }
    
    public var isParameter:Bool
        {
        return(false)
        }
    
    public var isImmediate:Bool
        {
        return(false)
        }
    
    public var acceptsAnyArity:Bool
        {
        return(false)
        }
    
    public var arity:Int
        {
        return(parameters.count)
        }
    
    public override var isType:Bool
        {
        return(true)
        }
    
    init(name:ArgonName)
        {
        self.name = name
        id = Argon.nextCounter
        super.init()
        }
    
    init(name:String)
        {
        self.name = ArgonName(name)
        id = Argon.nextCounter
        super.init()
        }
    
    public func add(handler:ArgonHandlerStatementNode)
        {
        handlers.append(handler)
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.pushContainer(self)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: self.locals.count * 8,comment:"// Method \(self.name.string)",stackFrameNumber: self.enclosingStackFrame!.number))
        var offset = +8
        for parameter in parameters
            {
            parameter.offsetFromBP = offset
            offset += 8
            }
        offset = -8
        for local in locals
            {
            local.offsetFromBP = offset
            try local.threeAddress(pass: pass)
            offset -= 8
            }
        if self.isPrimitive
            {
            pass.add(ThreeAddressInstruction(operation: .prim,operand1: primitiveNumber,comment:"// Invoke primitive \(primitiveNumber)"))
            }
        else
            {
            try statements.threeAddress(pass: pass)
            }
        pass.add(ThreeAddressInstruction(operation: .leave,operand1: self.locals.count * 8,comment:"// Leave Method \(self.name.string)"))
        pass.add(ThreeAddressInstruction(operation: .ret))
        pass.popContainer()
        }
    
    public func couldDispatch(forTraits:[ArgonTraitsNode]) -> Bool
        {
        guard forTraits.count == self.parameters.count else
            {
            return(false)
            }
        var index = 0
        for trait in forTraits
            {
            if !trait.inherits(from: parameters[index].traits)
                {
                return(false)
                }
            index += 1
            }
        return(true)
        }
    
    public func addParameter(_ parm:ArgonParameterNode)
        {
        parameters.append(parm)
        }
    
    public func scopeName() -> ArgonName
        {
        return(containingScope!.scopeName() + self.name)
        }
    
    public func enclosingWith() -> ArgonWithStatementNode?
        {
        return(containingScope?.enclosingWith())
        }
    
    public func enclosingMethod() -> ArgonMethodNode?
        {
        return(self)
        }
    
    public func allLocals() -> [ArgonLocalVariableNode]
        {
        var localList = self.locals
        localList.append(contentsOf: statements.allLocals())
        return(localList)
        }
    
    public func add(node: ArgonParseNode)
        {
        fatalError("Should not get called")
        }
        
    public func add(constant: ArgonNamedConstantNode)
        {
        constants.append(constant)
        }
    
    public func add(variable: ArgonVariableNode)
        {
        if !(variable is ArgonLocalVariableNode)
            {
            fatalError("Only locals can be added to methods")
            }
        let local = variable as! ArgonLocalVariableNode
        locals.append(local)
        local.scopedName = self.scopeName() + local.name.string
        }
    
    public func add(statement:ArgonMethodStatementNode)
        {
        statements.append(statement)
        }
    
    public func add(parameter:ArgonParameterNode)
        {
        parameters.append(parameter)
        }
    
    public override func resolve(name:ArgonName) -> ArgonParseNode?
        {
        for parm in parameters
            {
            if parm.name == name
                {
                return(parm)
                }
            }
        for local in locals
            {
            if local.name == name
                {
                return(local)
                }
            }
        return(containingScope?.resolve(name:name))
        }
    
    public func enclosingModule() -> ArgonParseModule
        {
        return(containingScope!.enclosingModule())
        }
    
    public func enclosingScope() -> ArgonParseScope?
        {
        return(containingScope)
        }
    
    public func resolveTraitsPointers(using compiler: ArgonCompiler) throws
        {
//        // try look us up
//        if !locations.hasCanonicalLocation
//            {
//            print("Traits \(name.string) missing canonicalised location")
//            let pointer = try compiler.traits(atName: self.name.string)
//            if !isPointerNil(pointer)
//                {
//                print("Traits \(name.string) added canonicalised location")
//                self.locations.canonicalLocation = ArgonMemoryStorageLocation(pointer!)
//                }
//            else
//                {
//                print("Traits \(name.string) could not resolve address")
//                }
//            }
//        for parameter in parameters
//            {
//            if parameter.type is ArgonTraitsNode
//                {
//                let traits = parameter.type as! ArgonTraitsNode
//                if traits.locations.hasCanonicalLocation
//                    {
//                    print("Founds traits \(traits.name.string) and pointer")
//                    parameter.traitsPointer = traits.locations.canonicalMemoryLocation.pointer
//                    }
//                }
//            else
//                {
//                let name = parameter.traits.name.string
//                print("Looking for traits \(name)")
//                let traitsPointer = try compiler.traits(atName: name)
//                if !isPointerNil(traitsPointer)
//                    {
//                    print("Found traits \(name) adding to parameter \(parameter.name)")
//                    parameter.traitsPointer = traitsPointer
//                    }
//                else
//                    {
//                    print("Could not resolve traits \(name) for parameter \(parameter.name)")
//                    }
//                }
//            }
        fatalError()
        }
    }
