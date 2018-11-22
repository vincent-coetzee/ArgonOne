//
//  ThreeAddressCodeGenerator.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ThreeAddressCodeGenerator
    {
    public var instructions:[VMInstruction] = []
    private var dataSegmentOffset = Argon.kDataSegmentStartOffset
    private var registerFile = ArgonRegisterFile(count: Argon.kNumberOfRegisters, floatingPoint: false)
    private var relocationTable = ArgonRelocationTable.shared
    private var pendingLabels:[String] = []
    private var currentStackFrame:ArgonStackFrame?
    private var currentCodeContainer:ArgonCodeContainer?
    
    public func reset()
        {
        registerFile = ArgonRegisterFile(count: Argon.kNumberOfRegisters, floatingPoint: false)
        }
    
    public func nextOffsetInDataSegment() -> Int
        {
        let offset = dataSegmentOffset
        dataSegmentOffset += 8
        return(offset)
        }
    
    public func generateCode(from input:[ThreeAddressInstruction],in container:ArgonCodeContainer) throws
        {
        currentCodeContainer = container
        instructions = []
        for instruction in input
            {
            try self.encode(instruction)
            }
        container.instructionList = VMInstructionList(instructions)
        }
    
    public func encode(_ statement:ThreeAddressInstruction) throws
        {
        if statement.stackFrameNumber != nil
            {
            currentStackFrame = ArgonStackFrame.stackFrame(at: statement.stackFrameNumber!)
            }
        let index = instructions.count
        statement.dump()
        switch(statement.operation)
            {
            case .none:
                instructions.append(.NOP())
            case .assign:
                try self.encodeAssign(statement)
            case .jump:
                let instruction = VMInstruction.BR(immediate: 0)
                instruction.target = statement.target.targetLabel
                instructions.append(instruction)
            case .jumpIfTrue:
                fallthrough
            case .jumpIfFalse:
                let register = statement.operand1!.locations.registerLocation
                if statement.operation == .jumpIfTrue
                    {
                    let instruction = VMInstruction.BRT(register1:register,immediate:0)
                    instruction.target = statement.target.targetLabel
                    instructions.append(instruction)
                    }
                else
                    {
                    let instruction = VMInstruction.BRF(register1:register,immediate:0)
                    instruction.target = statement.target.targetLabel
                    instructions.append(instruction)
                    }
                registerFile.returnRegister(register)
            case .eq:
                fallthrough
            case .gte:
                fallthrough
            case .gt:
                fallthrough
            case .lte:
                fallthrough
            case .lt:
                try self.encodeRelation(statement)
            case .param:
                try self.encodeParam(statement)
            case .make:
                try self.encodeMake(statement)
            case .dispatch:
                try self.encodeDispatch(statement)
            case .ret:
                try self.encodeRet(statement)
            case .and:
                fallthrough
            case .or:
                fallthrough
            case .xor:
                fallthrough
            case .add:
                fallthrough
            case .sub:
                fallthrough
            case .mul:
                fallthrough
            case .div:
                fallthrough
            case .mod:
                try self.encodeOperation(statement)
            case .call:
                try self.encodeCall(statement)
            case .not:
                try self.encodeUnary(statement)
            case .return:
                try self.encodeReturn(statement)
            case .halt:
                instructions.append(.HALT())
            case .nop:
                instructions.append(.NOP())
            case .enter:
                try self.encodeEnter(statement)
            case .leave:
                try self.encodeLeave(statement)
            case .spawn:
                try self.encodeSpawn(statement)
            case .prim:
                instructions.append(.PRIM(immediate: statement.operand1 as! Int))
            case .clear:
                try self.encodeClear(statement)
            case .handler:
                try self.encodeHandler(statement)
            case .signal:
                try self.encodeSignal(statement)
            default:
                fatalError("Operation \(statement.operation) not handled")
            }
        if instructions.count == index
            {
            if statement.label != nil
                {
                pendingLabels = [statement.label!]
                }
            }
        else
            {
            let instruction = instructions[index]
            if statement.lineTrace != nil
                {
                instructions[index].lineTrace = statement.lineTrace
                }
            if statement.label != nil
                {
                instruction.labels.append(statement.label!)
                }
            if !pendingLabels.isEmpty
                {
                instruction.labels = pendingLabels
                pendingLabels = []
                }
            for loop in index..<instructions.count
                {
                instructions[loop].dump()
                }
            }
        }
    
    public func encodeSignal(_ statement:ThreeAddressInstruction) throws
        {
        let constant = statement.operand1 as! ArgonConstantNode
        let symbol = constant.literalSymbol!
        instructions.append((VMInstruction.SIG(address:0)).wantsRelocation(of: {symbol.asArgonSymbol()}))
        }
    
    public func encodeHandler(_ statement:ThreeAddressInstruction) throws
        {
        let handler = statement.operand1 as! ArgonHandlerStatementNode
        instructions.append((VMInstruction.HAND(address: 0)).wantsRelocation(of: {handler.asArgonHandler()}))
        }
    
    public func encodeClear(_ statement:ThreeAddressInstruction) throws
        {
        var parameterCount = statement.operand1 as! Int
        parameterCount *= 8
        instructions.append(.ADD(immediate:parameterCount,register1:ArgonRegisterFile.SP,register2:ArgonRegisterFile.SP))
        }
    
    public func encodeSpawn(_ statement:ThreeAddressInstruction) throws
        {
        let closure = statement.operand1 as! ArgonClosureNode
        instructions.append((VMInstruction.SPAWN(address: 0)).wantsRelocation(of: {closure.asArgonClosure()}))
        }
    
    public func encodeEnter(_ statement:ThreeAddressInstruction) throws
        {
        let stackSizeInBytes = statement.operand1 as! Int
        instructions.append(.PUSH(register:ArgonRegisterFile.BP))
        instructions.append(.MOV(register1:ArgonRegisterFile.SP,register2:ArgonRegisterFile.BP))
        instructions.append(.SUB(immediate:stackSizeInBytes,register1:ArgonRegisterFile.SP,register2:ArgonRegisterFile.SP))
        }
    
    public func encodeCall(_ statement:ThreeAddressInstruction) throws
        {
        if case let ThreeAddressTarget.threeAddress(target) = statement.target
            {
            if !(target is ArgonClosureNode)
                {
                throw(CompilerError.callWithoutClosure)
                }
            let closure = target as! ArgonClosureNode
            instructions.append((VMInstruction.CALL(address: 0)).wantsRelocation(of: {closure.asArgonClosure()}))
            if statement.lhs != nil
                {
                statement.lhs!.locations.append(register: VMRegister(.R0))
                ArgonRegisterFile.R0.contents = statement.lhs!
                }
            }
        else
            {
            fatalError("Should not happen")
            }
        }
    
    public func encodeLeave(_ statement:ThreeAddressInstruction) throws
        {
        let stackSizeInBytes = statement.operand1 as! Int
        instructions.append(.ADD(immediate:stackSizeInBytes,register1:ArgonRegisterFile.SP,register2:ArgonRegisterFile.SP))
        instructions.append(.POP(register:ArgonRegisterFile.BP))
        }
    
    public func encodeUnary(_ statement:ThreeAddressInstruction) throws
        {
        let op1 = statement.operand1!
        var register1:VMRegister
        if op1.isStackBased
            {
            if op1.locations.hasRegisterLocation
                {
                register1 = op1.locations.registerLocation
                }
            else
                {
                register1 = try registerFile.allocateRegister(for: op1,with: self)
                }
            if register1.contents == nil || !register1.contents!.isSame(as: op1)
                {
                let stackBased = op1 as! ArgonStackBasedValue
                instructions.append(.MOV(register1:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP,register2:register1))
                register1.contents = op1
                }
            }
        else if op1.isGlobal
            {
            register1 = try loadGlobal(op1)
            }
        else
            {
            if !op1.locations.hasRegisterLocation
                {
                fatalError("Temporary should always be in a register")
                }
            register1 = op1.locations.registerLocation
            }
        let register2 = try registerFile.allocateRegister(for: nil,with:self)
        instructions.append(.NOT(register1:register1,register2:register2))
        register2.contents = statement.lhs!
        if statement.lhs!.isStackBased
            {
            let stackBased = statement.lhs as! ArgonStackBasedValue
            instructions.append(.MOV(register1: register2,register2:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP))
            }
        else if !statement.lhs!.isTemporary
            {
            registerFile.returnRegister(register2)
            }
        statement.lhs!.locations.append(register: register2)
        registerFile.returnRegister(register1)
        }
    
    private func loadOperand(_ operand:ThreeAddress) throws -> VMRegister
        {
        var register:VMRegister
        if operand.isStackBased
            {
            if operand.locations.hasRegisterLocation
                {
                register = operand.locations.registerLocation
                }
            else
                {
                register = try registerFile.allocateRegister(for: operand,with: self)
                }
            if !register.contains(operand)
                {
                let stackBased = operand as! ArgonStackBasedValue
                instructions.append(.MOV(register1:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP,register2:register))
                register.contents = operand
                }
            }
        else if operand.isGlobal
            {
            register = try loadGlobal(operand)
            }
        else if operand.isConstant || operand.isInteger
            {
            register = try loadConstant(operand)
            }
        else if operand.isSlot
            {
            register = try loadSlot(operand)
            }
        else if operand.isPointer
            {
            register = try loadPointer(operand)
            }
        else if operand.isTemporary
            {
            if !operand.locations.hasRegisterLocation
                {
                throw(CompilerError.temporaryNotInRegister)
                }
            register = operand.locations.registerLocation
            }
        else
            {
            throw(CompilerError.invalidOperandType)
            }
        return(register)
        }
    
    public func encodeOperation(_ statement:ThreeAddressInstruction) throws
        {
        let op1 = statement.operand1!
        let op2 = statement.operand2!
        let register1 = try self.loadOperand(op1)
        let register2 = try self.loadOperand(op2)
        let register3 = try registerFile.allocateRegister(for: statement.lhs!,with: self)
        if register3.contains(statement.lhs!)
            {
            if !statement.lhs!.isTemporary
                {
                registerFile.returnRegister(register3)
                }
            return
            }
        let operation = statement.operation
        switch(operation)
            {
            case .and:
                instructions.append(.AND(register1:register1,register2:register2,register3:register3))
            case .or:
                instructions.append(.OR(register1:register1,register2:register2,register3:register3))
            case .xor:
                instructions.append(.XOR(register1:register1,register2:register2,register3:register3))
            case .add:
                instructions.append(.ADD(register1:register1,register2:register2,register3:register3))
            case .sub:
                instructions.append(.SUB(register1:register1,register2:register2,register3:register3))
            case .mul:
                instructions.append(.MUL(register1:register1,register2:register2,register3:register3))
            case .div:
                instructions.append(.DIV(register1:register1,register2:register2,register3:register3))
            case .mod:
                instructions.append(.MOD(register1:register1,register2:register2,register3:register3))
            default:
                break
            }
        register3.contents = statement.lhs!
        statement.lhs!.locations.append(register: register3)
        if statement.operand1!.isPointer
            {
            statement.lhs!.locations.track = true
            }
        statement.lhs!.locations.append(register: register3)
        if statement.lhs!.isStackBased
            {
            let stackBased = statement.lhs as! ArgonStackBasedValue
            instructions.append(.MOV(register1: register3,register2:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP))
            }
        if !statement.lhs!.isTemporary
            {
            registerFile.returnRegister(register3)
            }
        registerFile.returnRegister(register2)
        registerFile.returnRegister(register1)
        }
    
    public func loadPointer(_ operand:ThreeAddress,_ incoming:VMRegister? = nil) throws -> VMRegister
        {
        var register:VMRegister
        if incoming != nil
            {
            register = incoming!
            }
        else
            {
            register = try registerFile.allocateRegister(for: operand, with: self)
            }
        if register.contains(operand)
            {
            return(register)
            }
        let pointer = operand as! ThreeAddressPointer
        let address = pointer.address
        if address.locations.hasRegisterLocation && incoming == nil
            {
            return(address.locations.registerLocation)
            }
        if address.isStackBased
            {
            let stackBased = address as! ArgonStackBasedValue
            instructions.append(.MOV(register1: ArgonRegisterFile.BP,plus: stackBased.offsetFromBP,register2: register))
            register.contents = operand
            operand.locations.append(register: register)
            }
        else
            {
            fatalError("Invalid type of address in loadPointer")
            }
        return(register)
        }
    
    public func loadSlot(_ operand:ThreeAddress) throws -> VMRegister
        {
        let register = try registerFile.allocateRegister(for: operand, with: self)
        let slot = operand as! ArgonSlotNode
        instructions.append(.MOV(address: 0,into: register))
        return(register)
        }
    
    public func encodeRet(_ statement:ThreeAddressInstruction) throws
        {
        instructions.append(.RET())
        }
    
    public func encodeDispatch(_ statement:ThreeAddressInstruction) throws
        {
        let method = statement.operand1 as! ArgonGenericMethodNode
        let count = statement.operand2 as! Int
        instructions.append((VMInstruction.DSP(address: 0, count: count)).wantsRelocation(of: {method.asArgonGenericMethod()}))
        if statement.lhs!.isStackBased
            {
            let stackBased = statement.lhs as! ArgonStackBasedValue
            instructions.append(.MOV(register1: ArgonRegisterFile.R0,register2:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP))
            }
        else if statement.lhs!.isGlobal
            {
            let global = statement.lhs! as! ArgonGlobalVariableNode
            let instruction = VMInstruction.STORE(register1: ArgonRegisterFile.R0,address:0)
            instruction.wantsRelocation(of: {global.asArgonGlobal()})
            instructions.append(instruction)
            }
        else if statement.lhs!.isTemporary
            {
            var register:VMRegister
            if statement.lhs!.locations.hasRegisterLocation
                {
                register = statement.lhs!.locations.registerLocation
                }
            else
                {
                register = try registerFile.allocateRegister(for: statement.lhs!,with: self)
                register.contents = statement.lhs!
                }
            if register.register == .R0
                {
                print("halt")
                }
            statement.lhs!.locations.append(register: register)
            instructions.append(.MOV(register1:ArgonRegisterFile.R0,register2:register))
            }
        else
            {
            throw(CompilerError.invalidOperandType)
            }
        }
    
    public func encodeMake(_ statement:ThreeAddressInstruction) throws
        {
        let count = statement.operand2 as! Int
        instructions.append(.MAKE(immediate: count))
        if statement.lhs!.isStackBased
            {
            let stackBased = statement.lhs as! ArgonStackBasedValue
            instructions.append(.MOV(register1: ArgonRegisterFile.R0,register2:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP))
            }
        else if statement.lhs!.isGlobal
            {
            let global = statement.lhs! as! ArgonGlobalVariableNode
            let instruction = VMInstruction.STORE(register1: ArgonRegisterFile.R0,address:0)
            instruction.wantsRelocation(of: {global.asArgonGlobal()})
            instructions.append(instruction)
            }
        else if statement.lhs!.isTemporary
            {
            var register:VMRegister
            if statement.lhs!.locations.hasRegisterLocation
                {
                register = statement.lhs!.locations.registerLocation
                }
            else
                {
                register = try registerFile.allocateRegister(for: statement.lhs!,with: self)
                register.contents = statement.lhs!
                }
            statement.lhs!.locations.append(register: register)
            instructions.append(.MOV(register1:ArgonRegisterFile.R0,register2:register))
            register.contents = statement.lhs
            statement.lhs!.locations.removeAllRegisterLocations()
            statement.lhs!.locations.append(register: register)
            registerFile.returnRegister(register)
            }
        }
    
    public func encodeParam(_ statement:ThreeAddressInstruction) throws
        {
        if statement.operand1!.isStackBased
            {
            instructions.append(.PUSH(immediate: (statement.operand1 as! ArgonStackBasedValue).offsetFromBP,register: ArgonRegisterFile.BP))
            }
        else if statement.operand1!.isTemporary
            {
            if !statement.operand1!.locations.hasRegisterLocation
                {
                throw(CompilerError.temporaryNotInRegister)
                }
            let register = statement.operand1!.locations.registerLocation
            instructions.append(.PUSH(register: register))
            registerFile.returnRegister(register)
            }
        else if statement.operand1!.isGlobal
            {
            let register = try self.loadGlobal(statement.operand1!)
            instructions.append(.PUSH(register: register))
            registerFile.returnRegister(register)
            }
        else if statement.operand1!.isConstant
            {
            let constant = statement.operand1 as! ArgonConstantValue
            switch(constant.traits.name.string)
                {
                case "String":
                    instructions.append((VMInstruction.PUSH(address:0)).wantsRelocation(of: {constant.stringValue.asArgonString()}))
                case "Symbol":
                    instructions.append((VMInstruction.PUSH(address:0)).wantsRelocation(of: {constant.symbolValue.asArgonSymbol()}))
                case "Integer":
                    instructions.append(.PUSH(immediate: constant.integerValue))
                case "Boolean":
                    instructions.append(.PUSH(immediate: constant.booleanValue ? 1 : 0))
                default:
                    break
                }
            }
        else if statement.operand1! is ArgonTraitsNode
            {
            instructions.append((VMInstruction.PUSH(address: 0)).wantsRelocation(of: {(statement.operand1 as! ArgonTraitsNode).asArgonTraits()}))
            }
        else if statement.operand1! is ArgonClosureNode
            {
            instructions.append((VMInstruction.PUSH(address: 0)).wantsRelocation(of: {(statement.operand1 as! ArgonClosureNode).asArgonClosure()}))
            }
        }
    
    public func encodeReturn(_ statement:ThreeAddressInstruction) throws
        {
        if statement.operand1!.isStackBased
            {
            instructions.append(.MOV(register1: ArgonRegisterFile.BP,plus: (statement.operand1 as! ArgonStackBasedValue).offsetFromBP,register2: ArgonRegisterFile.R0))
            }
        else if statement.operand1!.isGlobal
            {
            let register = try loadGlobal(statement.operand1!)
            instructions.append(.MOV(register1: register,register2: ArgonRegisterFile.R0))
            registerFile.returnRegister(register)
            }
        else if statement.operand1!.isTemporary
            {
            if !statement.operand1!.locations.hasRegisterLocation
                {
                throw(CompilerError.temporaryNotInRegister)
                }
            let register = statement.operand1!.locations.registerLocation
            instructions.append(.MOV(register1: register,register2: ArgonRegisterFile.R0))
            register.contents = statement.operand1
            statement.operand1!.locations.append(register: register)
            registerFile.returnRegister(register)
            }
        else if statement.operand1!.isConstant
            {
            let constant = statement.operand1 as! ArgonConstantValue
            switch(constant.traits.name.string)
                {
                case "String":
                    instructions.append((VMInstruction.MOV(address:0,into:ArgonRegisterFile.R0)).wantsRelocation(of: {constant.stringValue.asArgonString()}))
                case "Symbol":
                    instructions.append((VMInstruction.MOV(address:0,into:ArgonRegisterFile.R0)).wantsRelocation(of: {constant.symbolValue.asArgonSymbol()}))
                case "Integer":
                    instructions.append(.MOV(immediate: constant.integerValue,into: ArgonRegisterFile.R0))
                case "Boolean":
                    instructions.append(.MOV(immediate: constant.booleanValue ? 1 : 0,into: ArgonRegisterFile.R0))
                default:
                    break
                }
            }
        }
    
    public func encodeRelation(_ statement:ThreeAddressInstruction) throws
        {
        let op1 = statement.operand1!
        let op2 = statement.operand2!
        var register1:VMRegister?
        if op1.isTemporary
            {
            register1 = op1.locations.registerLocation
            }
        else if op1.isLocal
            {
            if op1.locations.hasRegisterLocation
                {
                register1 = op1.locations.registerLocation
                }
            else
                {
                let local = op1 as! ArgonLocalVariableNode
                register1 = try registerFile.allocateRegister(for: local,with: self)
                if register1!.contents == nil || !register1!.contents!.isSame(as: local)
                    {
                    instructions.append(.MOV(register1:ArgonRegisterFile.BP,plus:local.offsetFromBP,register2: register1!))
                    op1.locations.removeAllRegisterLocationsThenAdd(register: register1!)
                    register1!.contents = op1
                    }
                }
            }
        else if op1.isConstant
            {
            register1 = try loadConstant(op1)
            }
        else if op1.isGlobal
            {
            register1 = try loadGlobal(op1)
            }
        var register2:VMRegister?
        if op2.isTemporary
            {
            register2 = op2.locations.registerLocation
            }
        else if op2.isLocal
            {
            register2 = try self.loadStackBasedOperand(op2)
            }
        else if op2.isConstant
            {
            register2 = try self.loadConstant(op2)
            }
        else if op2.isGlobal
            {
            register2 = try loadGlobal(op2)
            }
        let register3 = try registerFile.allocateRegister(for: statement.lhs!,with: self)
        statement.lhs!.locations.removeAllRegisterLocationsThenAdd(register: register3)
        register3.contents = statement.lhs!
        if statement.operation == .eq
            {
            instructions.append(.EQ(register1:register1!,register2: register2!,register3:register3))
            }
        else if statement.operation == .lte
            {
            instructions.append(.LTE(register1:register1!,register2: register2!,register3:register3))
            }
        else if statement.operation == .lt
            {
            instructions.append(.LT(register1:register1!,register2: register2!,register3:register3))
            }
        else if statement.operation == .gte
            {
            instructions.append(.GTE(register1:register1!,register2: register2!,register3:register3))
            }
        else if statement.operation == .gt
            {
            instructions.append(.GT(register1:register1!,register2: register2!,register3:register3))
            }
        if statement.lhs!.isStackBased
            {
            let stackBased = statement.lhs as! ArgonStackBasedValue
            instructions.append(.MOV(register1: register3,register2:ArgonRegisterFile.BP,plus:stackBased.offsetFromBP))
            }
        if register1!.contents!.isConstant
            {
            register1!.contents!.locations.removeAllRegisterLocations()
            register1!.contents = nil
            }
        if register2!.contents!.isConstant
            {
            register2!.contents!.locations.removeAllRegisterLocations()
            register2!.contents = nil
            }
        statement.lhs!.locations.removeAllRegisterLocationsThenAdd(register: register3)
        registerFile.returnRegister(register1!)
        registerFile.returnRegister(register2!)
        if !statement.lhs!.isTemporary
            {
            registerFile.returnRegister(register3)
            }
        }
    
    @discardableResult
    private func loadConstant(_ operand:ThreeAddress,_ existing:VMRegister? = nil) throws -> VMRegister
        {
        var register:VMRegister
        if existing != nil
            {
            register = existing!
            }
        else
            {
            register = try registerFile.allocateRegister(for: operand,with: self)
            }
        if register.contains(operand)
            {
            operand.locations.removeAllRegisterLocationsThenAdd(register: register)
            return(register)
            }
        if operand.isConstant
            {
            let constant = operand as! ArgonConstantValue
            switch(constant.traits.name.string)
                {
                case "Integer":
                    instructions.append(.MOV(immediate: constant.integerValue,into: register))
                case "String":
                    instructions.append((VMInstruction.MOV(address:0,into: register)).wantsRelocation(of: {constant.stringValue.asArgonString()}))
                case "Boolean":
                    instructions.append(.MOV(immediate: constant.booleanValue ? 1 : 0,into: register))
                case "Symbol":
                    instructions.append((VMInstruction.MOV(address:0,into: register)).wantsRelocation(of: {constant.symbolValue.asArgonSymbol()}))
                default:
                    fatalError("Constant of \(constant.traits.name.string) not handled")
                }
            }
        else if operand.isInteger
            {
            let value = operand as! Int
            instructions.append(.MOV(immediate: value,into: register))
            }
        register.contents = operand
        operand.locations.removeAllRegisterLocationsThenAdd(register: register)
        return(register)
        }
    
    @discardableResult
    private func loadStackBasedOperand(_ operand:ThreeAddress,_ incoming:VMRegister? = nil) throws -> VMRegister
        {
        var register:VMRegister
        if incoming != nil && incoming!.contains(operand)
            {
            operand.locations.removeAllRegisterLocationsThenAdd(register: incoming!)
            return(incoming!)
            }
        if operand.locations.hasRegisterLocation && incoming == nil
            {
            let location = operand.locations.registerLocation
            if location.contents != nil && location.contents!.isSame(as: operand)
                {
                return(operand.locations.registerLocation)
                }
            }
        if incoming != nil
            {
            register = incoming!
            }
        else
            {
            register = try registerFile.allocateRegister(for: operand,with: self)
            }
        if register.contains(operand)
            {
            operand.locations.removeAllRegisterLocationsThenAdd(register: register)
            return(register)
            }
        let value = operand as! ArgonStackBasedValue
        if value.enclosingStackFrame != currentStackFrame
            {
            var stackFrame = currentStackFrame!
            if stackFrame != value.enclosingStackFrame
                {
                instructions.append(.MOV(register1: ArgonRegisterFile.BP,plus:0,register2:register))
                guard stackFrame.previous != nil else
                    {
                    throw(CompilerError.stackFrameMissing)
                    }
                stackFrame = stackFrame.previous!
                while stackFrame != value.enclosingStackFrame
                    {
                    instructions.append(.MOV(register1: register,plus:0,register2:register))
                    guard stackFrame.previous != nil else
                        {
                        throw(CompilerError.stackFrameMissing)
                        }
                    stackFrame = stackFrame.previous!
                    }
                instructions.append(.MOV(register1: register,plus: value.offsetFromBP,register2:register))
                register.contents = operand
                operand.locations.removeAllRegisterLocationsThenAdd(register: register)
                return(register)
                }
            }
        instructions.append(.MOV(register1: ArgonRegisterFile.BP,plus: value.offsetFromBP,register2:register))
        register.contents = operand
        operand.locations.removeAllRegisterLocationsThenAdd(register: register)
        return(register)
        }
    
    @discardableResult
    private func loadGlobal(_ operand:ThreeAddress,_ incoming:VMRegister? = nil) throws -> VMRegister
        {
        var register:VMRegister
        let global = operand as! ArgonGlobalVariableNode
        if incoming != nil
            {
            register = incoming!
            }
        else
            {
            register = try registerFile.allocateRegister(for: operand,with: self)
            }
        if register.contains(operand)
            {
            operand.locations.removeAllRegisterLocationsThenAdd(register: register)
            return(register)
            }
        let instruction = VMInstruction.LOAD(address: 0, register: register)
        instruction.wantsRelocation(of: {global.asArgonGlobal()})
        instructions.append(instruction)
        register.contents = operand
        operand.locations.removeAllRegisterLocationsThenAdd(register: register)
        return(register)
        }
    
    private func loadPointerDereference(_ operand:ThreeAddress) throws -> VMRegister
        {
        let pointerContents = operand as! ThreeAddressContentsOfPointer
        let pointer = pointerContents.pointer
        if pointer.isPointerIn || pointer.isPointerTo
            {
            let address = pointer.address
            if address.isStackBased
                {
                let targetRegister = try self.loadStackBasedOperand(address)
                return(targetRegister)
                }
            else if address.isTemporary
                {
                if !address.locations.hasRegisterLocation
                    {
                    throw(CompilerError.temporaryNotInRegister)
                    }
                let targetRegister = address.locations.registerLocation
                targetRegister.contents = address
                address.locations.append(register: targetRegister)
                return(targetRegister)
                }
            else
                {
                throw(CompilerError.invalidRValue)
                }
            }
        else
            {
            throw(CompilerError.invalidRValue)
            }
        }
    
    public func encodeAssign(_ statement:ThreeAddressInstruction) throws
        {
        if statement.lhs == nil
            {
            throw(CompilerError.invalidAssignInstruction)
            }
        let lhs = statement.lhs!
        if lhs.isLocal
            {
            let operand = statement.operand1!
            let local = lhs as! ArgonLocalVariableNode
            if operand.isTemporary
                {
                let temporary = operand as! ArgonTemporaryVariableNode
                if temporary.locations.hasRegisterLocation
                    {
                    let register = temporary.locations.registerLocation
                    instructions.append(.MOV(register1: register,register2: ArgonRegisterFile.BP,plus: local.offsetFromBP))
                    registerFile.returnRegister(register)
                    }
                else
                    {
                    throw(CompilerError.temporaryNotInRegister)
                    }
                }
            else if operand.isStackBased
                {
                let register = try registerFile.allocateRegister(for: lhs,with: self)
                if !register.contains(lhs)
                    {
                    let stackBased = operand as! ArgonStackBasedValue
                    instructions.append(.MOV(register1: ArgonRegisterFile.BP,plus: stackBased.offsetFromBP,register2:register))
                    }
                instructions.append(.MOV(register1: register,register2: ArgonRegisterFile.BP,plus: local.offsetFromBP))
                register.contents = lhs
                lhs.locations.removeAllRegisterLocationsThenAdd(register: register)
                registerFile.returnRegister(register)
                }
            else if operand.isConstant || operand.isInteger
                {
                let register = try self.loadConstant(operand)
                instructions.append(.MOV(register1:register,register2: ArgonRegisterFile.BP,plus: local.offsetFromBP))
                registerFile.returnRegister(register)
                }
            else if operand.isGlobal
                {
                let register = try self.loadGlobal(operand)
                instructions.append(.MOV(register1:register,register2: ArgonRegisterFile.BP,plus: local.offsetFromBP))
                registerFile.returnRegister(register)
                }
            else if operand.isMethod
                {
                let method = operand as! ArgonGenericMethodNode
                instructions.append((VMInstruction.DSP(address:0,count: method.parameterCount)).wantsRelocation(of: {method.asArgonGenericMethod()}))
                instructions.append(.MOV(register1:ArgonRegisterFile.R0,register2: ArgonRegisterFile.BP,plus: local.offsetFromBP))
                }
            else if operand.isClosure
                {
                let closure = operand as! ArgonClosureNode
                let register = try registerFile.allocateRegister(for: operand, with: self)
                instructions.append((VMInstruction.MOV(address:0,into:register)).wantsRelocation(of: {closure.asArgonClosure()}))
                instructions.append(.MOV(register1:register,register2: ArgonRegisterFile.BP,plus: local.offsetFromBP))
                register.contents = operand
                closure.locations.removeAllRegisterLocationsThenAdd(register: register)
                registerFile.returnRegister(register)
                }
            else if operand.isPointerDereference
                {
                let register = try loadPointerDereference(operand)
                register.contents = operand
                operand.locations.removeAllRegisterLocationsThenAdd(register: register)
                registerFile.returnRegister(register)
                }
            }
        else if lhs.isTemporary
            {
            let operand = statement.operand1!
            let temporary = lhs as! ArgonTemporaryVariableNode
            var register:VMRegister
            if !temporary.locations.hasRegisterLocation
                {
                register = try registerFile.allocateRegister(for: nil,with: self)
                defer
                    {
                    registerFile.returnRegister(register)
                    }
                temporary.locations.append(register: register)
                }
            else
                {
                register = temporary.locations.registerLocation
                }
            if operand.isTemporary
                {
                fatalError("Should not happen")
                }
            else if operand.isGlobal
                {
                try self.loadGlobal(operand,register)
                }
            else if operand.isStackBased
                {
                try self.loadStackBasedOperand(operand,register)
                registerFile.returnRegister(register)
                }
            else if operand.isConstant
                {
                try self.loadConstant(operand,register)
                registerFile.returnRegister(register)
                }
            else if operand.isMethod
                {
                let method = lhs as! ArgonGenericMethodNode
                instructions.append((VMInstruction.DSP(address:0,count: method.parameterCount)).wantsRelocation(of: {method.asArgonGenericMethod()}))
                instructions.append(.MOV(register1:ArgonRegisterFile.R0,register2: register))
                }
            else if operand.isClosure
                {
                let closure = operand as! ArgonClosureNode
                let register = try registerFile.allocateRegister(for: operand, with: self)
                instructions.append((VMInstruction.MOV(address:0,into:register)).wantsRelocation(of: {closure.asArgonClosure()}))
                register.contents = operand
                closure.locations.append(register: register)
                registerFile.returnRegister(register)
                }
            else if operand.isPointerDereference
                {
                let register = try loadPointerDereference(operand)
                register.contents = operand
                operand.locations.append(register: register)
                registerFile.returnRegister(register)
                }
            }
        else if lhs.isGlobal
            {
            let operand = statement.operand1!
            let global = lhs as! ArgonGlobalVariableNode
            if operand.isTemporary
                {
                let temporary = operand as! ArgonTemporaryVariableNode
                guard temporary.locations.hasRegisterLocation else
                    {
                    throw(CompilerError.temporaryNotInRegister)
                    }
                let register = temporary.locations.registerLocation
                instructions.append((VMInstruction.STORE(register1: register,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                registerFile.returnRegister(register)
                }
            else if operand.isGlobal
                {
                let register = try self.loadGlobal(operand)
                instructions.append((VMInstruction.STORE(register1: register,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                registerFile.returnRegister(register)
                }
            else if operand.isStackBased
                {
                let register = try self.loadStackBasedOperand(operand)
                instructions.append((VMInstruction.STORE(register1: register,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                registerFile.returnRegister(register)
                }
            else if operand.isConstant
                {
                let register = try self.loadConstant(operand)
                instructions.append((VMInstruction.STORE(register1: register,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                registerFile.returnRegister(register)
                }
            else if operand.isMethod
                {
                let method = lhs as! ArgonGenericMethodNode
                instructions.append((VMInstruction.DSP(address:0,count: method.parameterCount)).wantsRelocation(of: {method.asArgonGenericMethod()}))
                instructions.append((VMInstruction.STORE(register1: ArgonRegisterFile.R0,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                }
            else if operand.isClosure
                {
                let closure = operand as! ArgonClosureNode
                let register = try registerFile.allocateRegister(for: operand, with: self)
                instructions.append((VMInstruction.MOV(address:0,into:register)).wantsRelocation(of: {closure.asArgonClosure()}))
                instructions.append((VMInstruction.STORE(register1: register,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                register.contents = operand
                closure.locations.append(register: register)
                registerFile.returnRegister(register)
                }
            else if operand.isPointerDereference
                {
                let register = try loadPointerDereference(operand)
                instructions.append((VMInstruction.STORE(register1: register,address:0)).wantsRelocation(of: {global.asArgonGlobal()}))
                register.contents = operand
                operand.locations.append(register: register)
                registerFile.returnRegister(register)
                }
            }
        else if lhs.isCapturedValue
            {
            let operand = statement.operand1!
            let captured = lhs as! ArgonCapturedValue
            if operand.isTemporary
                {
                let temporary = operand as! ArgonTemporaryVariableNode
                guard temporary.locations.hasRegisterLocation else
                    {
                    throw(CompilerError.temporaryNotInRegister)
                    }
                let register = temporary.locations.registerLocation
                instructions.append(VMInstruction.MOV(register1:register,register2:ArgonRegisterFile.BP,plus: captured.offsetFromBP))
                registerFile.returnRegister(register)
                }
            else if operand.isGlobal
                {
                let register = try self.loadGlobal(operand)
                if register.contents == nil || !register.contents!.isSame(as: operand)
                    {
                    instructions.append(VMInstruction.MOV(register1:register,register2:ArgonRegisterFile.BP,plus: captured.offsetFromBP))
                    }
                registerFile.returnRegister(register)
                }
            else if operand.isStackBased
                {
                let register = try self.loadStackBasedOperand(operand)
                if register.contents == nil || register.contents!.isSame(as: operand)
                    {
                    instructions.append(VMInstruction.MOV(register1:register,register2:ArgonRegisterFile.BP,plus: captured.offsetFromBP))
                    }
                registerFile.returnRegister(register)
                }
            else if operand.isConstant
                {
                let register = try self.loadConstant(operand)
                instructions.append(VMInstruction.MOV(register1:register,register2:ArgonRegisterFile.BP,plus: captured.offsetFromBP))
                registerFile.returnRegister(register)
                }
            else if operand.isMethod
                {
                let method = lhs as! ArgonGenericMethodNode
                instructions.append((VMInstruction.DSP(address:0,count: method.parameterCount)).wantsRelocation(of: {method.asArgonGenericMethod()}))
                let register = try registerFile.allocateRegister(for: operand, with: self)
                instructions.append(.MOV(register1:ArgonRegisterFile.R0,register2: register))
                registerFile.returnRegister(register)
                }
            else if operand.isClosure
                {
                let closure = operand as! ArgonClosureNode
                let register = try registerFile.allocateRegister(for: operand, with: self)
                instructions.append((VMInstruction.MOV(address:0,into:register)).wantsRelocation(of: {closure.asArgonClosure()}))
                register.contents = operand
                closure.locations.append(register: register)
                registerFile.returnRegister(register)
                }
            else if operand.isPointerDereference
                {
                let register = try loadPointerDereference(operand)
                register.contents = operand
                operand.locations.append(register: register)
                registerFile.returnRegister(register)
                }
            }
        else if lhs.isPointerDereference
            {
            let pointerContents = lhs as! ThreeAddressContentsOfPointer
            let pointer = pointerContents.pointer
            let operand = statement.operand1!
            var sourceRegister:VMRegister
            if operand.isTemporary
                {
                if !operand.locations.hasRegisterLocation
                    {
                    throw(CompilerError.temporaryNotInRegister)
                    }
                sourceRegister = operand.locations.registerLocation
                }
            else if operand.isConstant || operand.isInteger
                {
                sourceRegister = try self.loadConstant(operand)
                }
            else if operand.isStackBased
                {
                sourceRegister = try self.loadStackBasedOperand(operand)
                }
            else
                {
                throw(CompilerError.unsupportedOperandType)
                }
            if pointer.isPointerIn || pointer.isPointerTo
                {
                let address = pointer.address
                if address.isStackBased
                    {
                    let targetRegister = try self.loadStackBasedOperand(address)
                    instructions.append(.MOV(register1: sourceRegister,register2: targetRegister,plus:0))
                    registerFile.returnRegister(targetRegister)
                    }
                else if address.isTemporary
                    {
                    if !address.locations.hasRegisterLocation
                        {
                        throw(CompilerError.temporaryNotInRegister)
                        }
                    let targetRegister = address.locations.registerLocation
                    targetRegister.contents = address
                    address.locations.removeAllRegisterLocationsThenAdd(register: targetRegister)
                    instructions.append(.MOV(register1: sourceRegister,register2: targetRegister,plus:0))
                    registerFile.returnRegister(targetRegister)
                    }
                else
                    {
                    throw(CompilerError.invalidRValue)
                    }
                }
            else
                {
                throw(CompilerError.invalidRValue)
                }
            registerFile.returnRegister(sourceRegister)
            }
        else
            {
            throw(CompilerError.invalidAssignInstruction)
            }
        }
    }
