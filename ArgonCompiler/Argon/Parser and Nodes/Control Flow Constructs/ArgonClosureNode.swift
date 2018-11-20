//
//  ArgonClosureNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonClosureNode:ArgonStoredValueNode,ArgonParseScope,ArgonCodeContainer,ArgonRelocatable
    {
    private static var closureNumber = 1
    
    public var lineTrace:ArgonLineTrace?
    public var fullName:ArgonName = .null
    public var inductionVariables:[ArgonParameterNode] = []
    public var resultType:ArgonType?
    public var locals:[ArgonLocalVariableNode] = []
    public var statements = ArgonStatementList()
    public var containingScope:ArgonParseScope
    public var constants:[ArgonNamedConstantNode] = []
    public var threeAddressInstructions:[ThreeAddressInstruction] = []
    public var instructionList = VMInstructionList()
    private var capturedValues:[ArgonName:ArgonCapturedValue] = [:]
    public private(set) var id:Int = 0
    
    public func enclosingClosure() -> ArgonClosureNode?
        {
        return(self)
        }
    
    public func asArgonClosure() -> ArgonClosure
        {
        let new = ArgonClosure(fullName: fullName.string)
        new.inductionVariables = self.inductionVariables.map {$0.name.string}
        new.resultType = self.resultType?.traits.asArgonTraits() ?? ArgonRelocationTable.shared.traits(at: "Argon::Void")!
        new.code = ArgonCodeBlock(instructionList)
        new.id = self.id
        return(new)
        }
        
    public var inductionVariableCount:Int
        {
        return(inductionVariables.count)
        }
    
    public var resultTraits:ArgonTraitsNode
        {
        return(resultType?.traits ?? ArgonStandardsNode.shared.voidTraits)
        }
    
    public override var traits:ArgonTraitsNode
        {
        return(ArgonStandardsNode.shared.closureTraits)
        }
    
    public override var isClosure:Bool
        {
        return(true)
        }
    
    public var lastLHS: ThreeAddress
        {
        return(threeAddressInstructions.last!.lhs!)
        }
    
    public func inductionVariable(at index:Int) -> ArgonParameterNode?
        {
        if index <= inductionVariables.count
            {
            return(inductionVariables[index])
            }
        return(nil)
        }
    
    public func add(_ instruction: ThreeAddressInstruction) -> Int
        {
        let offset = threeAddressInstructions.count
        threeAddressInstructions.append(instruction)
        return(offset)
        }
    
    public func optimize(with: ThreeAddressOptimizer) throws
        {
        }
    
    public func generateCode(with generator:ThreeAddressCodeGenerator) throws
        {
        print("Gnerating code for closure")
        try generator.generateCode(from: threeAddressInstructions,in:self)
        }
    
    public func dump()
        {
        print("Dumping for Closure \(self.name.string) \(self.inductionVariables.map{$0.traits.name.string})")
        instructionList.dump()
        }
    
    init(containingScope:ArgonParseScope,moduleName:ArgonName)
        {
        id = Argon.nextCounter
        let aName = "CLOSURE-\(ArgonClosureNode.closureNumber)"
        self.fullName = ArgonName(moduleName.string,aName)
        self.containingScope = containingScope
        super.init(name:ArgonName(aName))
        ArgonClosureNode.closureNumber += 1
        }
    
    public func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + self.name)
        }
    
    public func enclosingWith() -> ArgonWithStatementNode?
        {
        return(containingScope.enclosingWith())
        }
        
    public func enclosingMethod() -> ArgonMethodNode?
        {
        return(containingScope.enclosingMethod())
        }
        
    public func enclosingModule() -> ArgonParseModule
        {
        return(containingScope.enclosingModule())
        }
    
    public func add(node: ArgonParseNode)
        {
        fatalError("Should never be called")
        }
    
    public func add(constant: ArgonNamedConstantNode)
        {
        constants.append(constant)
        }
        
    public func add(variable: ArgonVariableNode)
        {
        guard let local = variable as? ArgonLocalVariableNode else
            {
            fatalError("Only locals can be added here")
            }
        locals.append(local)
        local.scopedName = self.scopeName() + local.name.string
        }
    
    public func enclosingScope() -> ArgonParseScope?
        {
        return(containingScope)
        }
        
    public func add(statement:ArgonMethodStatementNode)
        {
        statements.append(statement)
        }
    
    public override func resolve(name: ArgonName) -> ArgonParseNode?
        {
        if let value = self.capturedValues[name]
            {
            return(value)
            }
        for variable in inductionVariables
            {
            if variable.name == name
                {
                return(variable)
                }
            }
        for constant in constants
            {
            if constant.name == name
                {
                return(constant)
                }
            }
        for variable in locals
            {
            if variable.name == name
                {
                return(variable)
                }
            }
        return(containingScope.resolve(name:name))
        }
    
    public func add(induction:ArgonParameterNode)
        {
        inductionVariables.append(induction)
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        for captured in statements.touchedStoredValues()
            {
            let value = ArgonCapturedValue(name:captured.name,traits:captured.traits,original:captured)
            self.capturedValues[value.name] = value
            }
        pass.pushContainer(self)
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .enter, operand1: locals.count*8,comment: "// Start of Closure",stackFrameNumber:enclosingStackFrame!.number))
        var offset = 8
        for inductionVariable in inductionVariables
            {
            inductionVariable.offsetFromBP = offset
            offset += 8
            }
        offset = -8
        for local in locals
            {
            local.offsetFromBP = offset
            offset -= 8
            }
        for captured in Array(capturedValues.values).sorted(by: {$0.name < $1.name})
            {
            captured.offsetFromBP = offset
            var address:ThreeAddress
            if captured.originalValue is ThreeAddress
                {
                address = captured.originalValue as! ThreeAddress
                }
            else
                {
                try captured.originalValue.threeAddress(pass: pass)
                address = pass.lastLHS()
                }
            pass.add(ThreeAddressInstruction(lhs: captured,operand1: address,operation: .assign,operand2:nil))
            offset -= 8
            }
        try statements.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(operation: .leave, operand1: locals.count*8,comment: "// End of Closure"))
        pass.add(ThreeAddressInstruction(operation: .ret))
        pass.popContainer()
        }
    }
