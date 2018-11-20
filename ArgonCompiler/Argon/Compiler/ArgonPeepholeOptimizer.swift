//
//  ThreeAddressPeepholeOptimizer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum OperationReplacement
    {
    case operation(VMOperation)
    case variable(String)
    
    public var isOperation:Bool
        {
        switch(self)
            {
            case .operation:
                return(true)
            default:
                return(false)
            }
        }
    
    public var variableName:String
        {
        switch(self)
            {
            case .variable(let name):
                return(name)
            default:
                return("")
            }
        }
    
    public var operationValue:VMOperation
        {
        switch(self)
            {
            case .operation(let name):
                return(name)
            default:
                fatalError()
            }
        }
    }

public enum AddressReplacement
    {
    case address(ArgonWord)
    case variable(String)
    
    public var isAddress:Bool
        {
        switch(self)
            {
            case .address:
                return(true)
            default:
                return(false)
            }
        }
    
    public var variableName:String
        {
        switch(self)
            {
            case .variable(let name):
                return(name)
            default:
                return("")
            }
        }
    
    public var addressValue:ArgonWord
        {
        switch(self)
            {
            case .address(let name):
                return(name)
            default:
                fatalError()
            }
        }
    }

public enum RegisterReplacement
    {
    case register(MachineRegister)
    case variable(String)
    
    public var isRegister:Bool
        {
        switch(self)
            {
            case .register:
                return(true)
            default:
                return(false)
            }
        }
    
    public var variableName:String
        {
        switch(self)
            {
            case .variable(let name):
                return(name)
            default:
                return("")
            }
        }
    
    public var registerValue:MachineRegister
        {
        switch(self)
            {
            case .register(let name):
                return(name)
            default:
                fatalError()
            }
        }
    }

public enum ImmediateReplacement
    {
    case immediate(Int)
    case variable(String)
    case multiplied(String,String)
    case added(String,String)
    
    public var isImmediate:Bool
        {
        switch(self)
            {
            case .immediate:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isMultiplied:Bool
        {
        switch(self)
            {
            case .multiplied:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isAdded:Bool
        {
        switch(self)
            {
            case .added:
                return(true)
            default:
                return(false)
            }
        }
    
    public var variableNames:(String,String)
        {
        switch(self)
            {
            case .multiplied(let s1,let s2):
                return((s1,s2))
            case .added(let s1,let s2):
                return((s1,s2))
            default:
                return(("",""))
            }
        }
    
    public var variableName:String
        {
        switch(self)
            {
            case .variable(let name):
                return(name)
            default:
                return("")
            }
        }
    
    public var immediateValue:Int
        {
        switch(self)
            {
            case .immediate(let name):
                return(name)
            default:
                fatalError()
            }
        }
    }

public enum CaptureElement
    {
    case captureOperation(String)
    case captureRegister1(String)
    case captureRegister2(String)
    case captureRegister3(String)
    case captureImmediate(String)
    case captureAddress(String)
    
    case replaceImmediate(ImmediateReplacement)
    case replaceRegister1(RegisterReplacement)
    case replaceRegister2(RegisterReplacement)
    case replaceRegister3(RegisterReplacement)
    case replaceAddress(AddressReplacement)
    case replaceOperation(OperationReplacement)
    case replaceMode(VMInstructionMode)
    case compareRegister1To(RegisterReplacement)
    case compareRegister2To(RegisterReplacement)
    case compareRegister3To(RegisterReplacement)
    case compareImmediateTo(ImmediateReplacement)
    case compareOperationTo(OperationReplacement)
    case compareAddressTo(AddressReplacement)
    case ignore
    }

public enum ElementVariable
    {
    case operation(VMOperation)
    case address(ArgonWord)
    case immediate(Int)
    case register(MachineRegister)
    
    public var operationValue:VMOperation
        {
        switch(self)
            {
            case .operation(let value):
                return(value)
            default:
                fatalError()
            }
        }
    
    public var registerValue:MachineRegister
        {
        switch(self)
            {
            case .register(let value):
                return(value)
            default:
                fatalError()
            }
        }
    
    public var immediateValue:Int
        {
        switch(self)
            {
            case .immediate(let value):
                return(value)
            default:
                fatalError()
            }
        }
    
    public var addressValue:ArgonWord
        {
        switch(self)
            {
            case .address(let value):
                return(value)
            default:
                fatalError()
            }
        }
    }

public enum ReplacementElement
    {
    case replace(String)
    }

public struct LinePattern
    {
    public var elements:[CaptureElement] = []
    
    init(_ elements:CaptureElement...)
        {
        self.elements = elements
        }
    
    public func match(instruction:VMInstruction) throws -> Bool
        {
        var variables:[String:ElementVariable] = [:]
        for element in self.elements
            {
            switch(element)
                {
                case .captureOperation(let varName):
                    variables[varName] = ElementVariable.operation(instruction.operation)
                case .captureRegister1(let varName):
                    variables[varName] = ElementVariable.register(instruction.register1.register)
                case .captureRegister2(let varName):
                    variables[varName] = ElementVariable.register(instruction.register2.register)
                case .captureRegister3(let varName):
                    variables[varName] = ElementVariable.register(instruction.register3.register)
                case .captureImmediate(let varName):
                    variables[varName] = ElementVariable.immediate(instruction.immediate)
                case .captureAddress(let varName):
                    variables[varName] = ElementVariable.address(instruction.addressWord)
                case .compareRegister1To(let kind):
                    if kind.isRegister
                        {
                        if instruction.register1.register != kind.registerValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.register1.register != value!.registerValue
                            {
                            return(false)
                            }
                        }
                case .compareRegister2To(let kind):
                    if kind.isRegister
                        {
                        if instruction.register2.register != kind.registerValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.register2.register != value!.registerValue
                            {
                            return(false)
                            }
                        }
                case .compareRegister3To(let kind):
                    if kind.isRegister
                        {
                        if instruction.register3.register != kind.registerValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.register3.register != value!.registerValue
                            {
                            return(false)
                            }
                        }
                case .compareOperationTo(let kind):
                    if kind.isOperation
                        {
                        if instruction.operation != kind.operationValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.operation != value!.operationValue
                            {
                            return(false)
                            }
                        }
                case .compareImmediateTo(let kind):
                    if kind.isImmediate
                        {
                        if instruction.immediate != kind.immediateValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.immediate != value!.immediateValue
                            {
                            return(false)
                            }
                        }
                case .compareAddressTo(let kind):
                    if kind.isAddress
                        {
                        if instruction.addressWord != kind.addressValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.addressWord != value!.addressValue
                            {
                            return(false)
                            }
                        }
                default:
                    break
                }
            }
        return(true)
        }
    }

public class PeepholePattern
    {

    
    public var lines:[LinePattern] = []
    public var replacements:[LinePattern] = []
    public var name:String
    public var variables:[String:ElementVariable] = [:]
    
    public var lineCount:Int
        {
        return(lines.count)
        }
    
    init(name:String,lines:[LinePattern],replacements:[LinePattern])
        {
        self.name = name
        self.lines = lines
        self.replacements = replacements
        }
    
    public func optimize(_ list:VMInstructionList) throws -> Bool
        {
        variables = [:]
        var matched = true
        for index in 0..<lines.count
            {
            matched = try matched && self.compare(instruction: list.selectedInstruction(at: index),with: lines[index])
            if !matched
                {
                return(false)
                }
            }
        try self.replaceLines(list)
        return(true)
        }
    
    private func compare(instruction:VMInstruction,with linePattern:LinePattern) throws -> Bool
        {
        for element in linePattern.elements
            {
            switch(element)
                {
                case .captureOperation(let varName):
                    variables[varName] = ElementVariable.operation(instruction.operation)
                case .captureRegister1(let varName):
                    variables[varName] = ElementVariable.register(instruction.register1.register)
                case .captureRegister2(let varName):
                    variables[varName] = ElementVariable.register(instruction.register2.register)
                case .captureRegister3(let varName):
                    variables[varName] = ElementVariable.register(instruction.register3.register)
                case .captureImmediate(let varName):
                    variables[varName] = ElementVariable.immediate(instruction.immediate)
                case .captureAddress(let varName):
                    variables[varName] = ElementVariable.address(instruction.addressWord)
                case .compareRegister1To(let kind):
                    if kind.isRegister
                        {
                        if instruction.register1.register != kind.registerValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.register1.register != value!.registerValue
                            {
                            return(false)
                            }
                        }
                case .compareRegister2To(let kind):
                    if kind.isRegister
                        {
                        if instruction.register2.register != kind.registerValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.register2.register != value!.registerValue
                            {
                            return(false)
                            }
                        }
                case .compareRegister3To(let kind):
                    if kind.isRegister
                        {
                        if instruction.register3.register != kind.registerValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.register3.register != value!.registerValue
                            {
                            return(false)
                            }
                        }
                case .compareOperationTo(let kind):
                    if kind.isOperation
                        {
                        if instruction.operation != kind.operationValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.operation != value!.operationValue
                            {
                            return(false)
                            }
                        }
                case .compareImmediateTo(let kind):
                    if kind.isImmediate
                        {
                        if instruction.immediate != kind.immediateValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.immediate != value!.immediateValue
                            {
                            return(false)
                            }
                        }
                case .compareAddressTo(let kind):
                    if kind.isAddress
                        {
                        if instruction.addressWord != kind.addressValue
                            {
                            return(false)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value == nil || instruction.addressWord != value!.addressValue
                            {
                            return(false)
                            }
                        }
                default:
                    break
                }
            }
        return(true)
        }
    
    private func replace(linePattern: LinePattern) throws -> VMInstruction
        {
        let instruction = VMInstruction(0)
        for element in linePattern.elements
            {
            switch(element)
                {
                case .replaceImmediate(let kind):
                    if kind.isImmediate
                        {
                        instruction.immediate = kind.immediateValue
                        }
                    else if kind.isMultiplied
                        {
                        let names = kind.variableNames
                        let value1 = variables[names.0]
                        let value2 = variables[names.1]
                        if value1 != nil && value2 != nil
                            {
                            instruction.immediate = value1!.immediateValue*value2!.immediateValue
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                    else if kind.isAdded
                        {
                        let names = kind.variableNames
                        let value1 = variables[names.0]
                        let value2 = variables[names.1]
                        if value1 != nil && value2 != nil
                            {
                            instruction.immediate = value1!.immediateValue+value2!.immediateValue
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value != nil
                            {
                            instruction.immediate = value!.immediateValue
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                case .replaceOperation(let kind):
                    if kind.isOperation
                        {
                        instruction.operation = kind.operationValue
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value != nil
                            {
                            instruction.operation = value!.operationValue
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                case .replaceAddress(let kind):
                    if kind.isAddress
                        {
                        instruction.addressWord = kind.addressValue
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value != nil
                            {
                            instruction.addressWord = value!.addressValue
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                case .replaceRegister1(let kind):
                    if kind.isRegister
                        {
                        instruction.register1 = VMRegister(kind.registerValue)
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value != nil
                            {
                            instruction.register1 = VMRegister(value!.registerValue)
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                case .replaceRegister2(let kind):
                    if kind.isRegister
                        {
                        instruction.register2 = VMRegister(kind.registerValue)
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value != nil
                            {
                            instruction.register2 = VMRegister(value!.registerValue)
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
               case .replaceRegister3(let kind):
                    if kind.isRegister
                        {
                        instruction.register3 = VMRegister(kind.registerValue)
                        }
                    else
                        {
                        let value = variables[kind.variableName]
                        if value != nil
                            {
                            instruction.register3 = VMRegister(value!.registerValue)
                            }
                        else
                            {
                            throw(CompilerError.patternVariableMissing)
                            }
                        }
                case .replaceMode(let mode):
                    instruction.mode = mode
                default:
                    break
                    }
                }
            return(instruction)
            }
            
        private func replaceLines(_ list:VMInstructionList) throws
            {
            var newLines:[VMInstruction] = []
            for line in replacements
                {
                newLines.append(try self.replace(linePattern:line))
                }
            print("REPLACING :-")
            for instruction in list.selectedInstructions()
                {
                instruction.dump()
                }
            print("WITH")
            for line in newLines
                {
                line.dump()
                }
            print("END REPLACE")
            list.replaceSelectedInstructions(with: newLines)
            }
        }

public class ArgonPeepholeOptimizer
    {
    private var patterns:[PeepholePattern] = []
    
    init()
        {
        self.initPatterns()
        }
    
    public func initPatterns()
        {
        let l1 = LinePattern(.compareOperationTo(.operation(.ADD)),.compareImmediateTo(.immediate(0)),.compareRegister1To(.register(.SP)))
        self.patterns.append(PeepholePattern(name:"Elinate addition of 0 to SP",lines:[l1],replacements:[]))
        let l2 = LinePattern(.compareOperationTo(.operation(.SUB)),.compareImmediateTo(.immediate(0)),.compareRegister1To(.register(.SP)))
        self.patterns.append(PeepholePattern(name:"Elinate subtraction of 0 from SP",lines:[l2],replacements:[]))
        let l4 = LinePattern(.compareOperationTo(.operation(.MOVRR)),.captureRegister1("register1"),.captureRegister2("register2"))
        let l5 = LinePattern(.compareOperationTo(.operation(.MOVRN)),.compareRegister1To(.variable("register2")),.captureRegister2("register3"),.captureImmediate("immediate1"))
        let l6 = LinePattern(.replaceMode(.rightIndirect),.replaceOperation(.operation(.MOVRN)),.replaceRegister1(.variable("register1")),.replaceRegister2(.variable("register3")),.replaceImmediate(.variable("immediate1")))
        self.patterns.append(PeepholePattern(name:"Elinate redundant loads and stores 1",lines:[l4,l5],replacements:[l6]))
        let l7 = LinePattern(.compareOperationTo(.operation(.MOVIR)),.captureRegister1("register1"),.captureImmediate("immediate1"))
        let l8 = LinePattern(.compareOperationTo(.operation(.MOVIR)),.captureRegister1("register2"),.captureImmediate("immediate2"))
        let l9 = LinePattern(.compareOperationTo(.operation(.MUL)),.compareRegister1To(.variable("register1")),.compareRegister2To(.variable("register2")),.captureRegister3("register3"))
        let l10 = LinePattern(.replaceMode(.immediate),.replaceOperation(.operation(.MOVIR)),.replaceRegister1(.variable("register3")),.replaceImmediate(.multiplied("immediate1","immediate2")))
        self.patterns.append(PeepholePattern(name:"Elinate multiplication of constants",lines:[l7,l8,l9],replacements:[l10]))
        let l11 = LinePattern(.compareOperationTo(.operation(.MOVIR)),.captureRegister1("register1"),.captureImmediate("immediate1"))
        let l12 = LinePattern(.compareOperationTo(.operation(.MOVIR)),.captureRegister1("register2"),.captureImmediate("immediate2"))
        let l13 = LinePattern(.compareOperationTo(.operation(.ADD)),.compareRegister1To(.variable("register1")),.compareRegister2To(.variable("register2")),.captureRegister3("register3"))
        let l14 = LinePattern(.replaceMode(.immediate),.replaceOperation(.operation(.MOVIR)),.replaceRegister1(.variable("register3")),.replaceImmediate(.added("immediate1","immediate2")))
        self.patterns.append(PeepholePattern(name:"Elinate multiplication of constants",lines:[l11,l12,l13],replacements:[l14]))
        }
    
    public func apply(to list:VMInstructionList) throws
        {
        print("BEFORE PEEPHOLE OPTIMIZATION")
        list.dump()
        var changesWereMade = false
        repeat
            {
            for index in 0..<list.count
                {
                for pattern in patterns
                    {
                    let lineCount = pattern.lineCount
                    if list.ableToSelectInstructions(at: index, count: lineCount)
                        {
                        list.setSelection(index: index, count: lineCount)
                        let changed = try pattern.optimize(list)
                        changesWereMade = changed && changesWereMade
                        }
                    }
                }
            }
        while changesWereMade
        print("AFTER PEEPHOLE OPTIMIZATION")
        list.dump()
        }
    }
