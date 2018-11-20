//
//  VMInstruction.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory


public class VMInstruction:NSObject
    {
    public enum RelocationType:Int
        {
        case immediate = 0
        case address = 1
        }
    
    public static let kReservedMask = ArgonWord(15) << ArgonWord(60)
    public static let kReservedShift = ArgonWord(60)
    public static let kOperationMask = ArgonWord(127) << ArgonWord(56)
    public static let kOperationShift = ArgonWord(56)
    public static let kModeMask = ArgonWord(7) << ArgonWord(49)
    public static let kModeShift = ArgonWord(49)
    public static let kRegister1Mask = ArgonWord(127) << ArgonWord(42)
    public static let kRegister1Shift = ArgonWord(42)
    public static let kRegister2Mask = ArgonWord(127) << ArgonWord(35)
    public static let kRegister2Shift = ArgonWord(35)
    public static let kRegister3Mask = ArgonWord(127) << ArgonWord(28)
    public static let kRegister3Shift = ArgonWord(28)
    public static let kImmediateSignMask = ArgonWord(1) << ArgonWord(27)
    public static let kImmediateSignShift = ArgonWord(27)
    public static let kImmediateMask = ArgonWord(134217727) << ArgonWord(0)
    public static let kImmediateShift = ArgonWord(0)
    //
    //
    // Instruction definitions
    //
    //
    
    //
    // Branch to immediate
    //
    public static func BR(immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.BR,immediate:immediate,mode: .immediate))
        }
    
    //
    // Branch to immediate if register1 is true
    //
    public static func BRT(register1:VMRegister,immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.BRT,register1:register1,immediate:immediate,mode: .immediate))
        }
    
    //
    // Branch to immediate if register1 is false
    //
    public static func BRF(register1:VMRegister,immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.BRF,register1:register1,immediate:immediate,mode: .immediate))
        }
    
    //
    // register3 = register1 > register2
    //
    public static func GT(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.GT,register1:register1,register2:register2,register3:register3,mode: .register))
        }

    //
    // register3 = register1 >= register2
    //
    public static func GTE(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.GTE,register1:register1,register2:register2,register3:register3,mode: .register))
        }
    
    //
    // register3 = register1 <= register2
    //
    public static func LTE(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.LTE,register1:register1,register2:register2,register3:register3,mode: .register))
        }
    
    //
    // register3 = register1 < register2
    //
    public static func LT(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.LT,register1:register1,register2:register2,register3:register3,mode: .register))
        }
    
    //
    // register3 = register1 == register2
    //
    public static func EQ(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.EQ,register1:register1,register2:register2,register3:register3,mode: .register))
        }
    
    //
    // register3 = register1 != register2
    //
    public static func NEQ(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.NEQ,register1:register1,register2:register2,register3:register3,mode: .register))
        }
    
    //
    // Move immediate into register
    //
    public static func MOV(immediate:Int,into:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MOVIR,register1:into,immediate:immediate,mode: .immediate))
        }
    
    //
    // Move an address into a register
    //
    public static func MOV(address:ArgonWord,into:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MOVAR,register1:into,address:address,mode: .address))
        }
    
    //
    // Move a register into a register
    //
    public static func MOV(register1:VMRegister,register2:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MOVRR,register1:register1,register2:register2,mode:.register))
        }
    
    //
    // Move [immediate+register1] into register2
    //
    public static func MOV(register1:VMRegister,plus:Int,register2:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MOVNR,register1:register1,register2:register2,immediate:plus,mode:.leftIndirect))
        }
    
    //
    // Move register1 into [immediate+register2]
    //
    public static func MOV(register1:VMRegister,register2:VMRegister,plus:Int) -> VMInstruction
        {
        return(VMInstruction(.MOVRN,register1:register1,register2:register2,immediate:plus,mode:.rightIndirect))
        }
    
    //
    // register3 = register1 AND register2
    //
    public static func AND(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.AND,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register3 = register1 OR register2
    //
    public static func OR(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.OR,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register3 = register1 XOR register2
    //
    public static func XOR(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.XOR,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register3 = register1 + register2
    //
    public static func ADD(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.ADD,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register2 = register1 - immediate
    //
    public static func SUB(immediate:Int,register1:VMRegister,register2:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.SUB,register1:register1,register2:register2,immediate: immediate,mode:.immediate))
        }
    
    //
    // register2 = register1 + immediate
    //
    public static func ADD(immediate:Int,register1:VMRegister,register2:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.ADD,register1:register1,register2:register2,immediate:immediate,mode:.immediate))
        }
    
    //
    // register3 = register1 - register2
    //
    public static func SUB(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.SUB,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register3 = register1 * register2
    //
    public static func MUL(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MUL,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register3 = register1 / register2
    //
    public static func DIV(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.DIV,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register3 = register1 % register2
    //
    public static func MOD(register1:VMRegister,register2:VMRegister,register3:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MOD,register1:register1,register2:register2,register3:register3,mode:.register))
        }
    
    //
    // register2 = NOT register1
    //
    public static func NOT(register1:VMRegister,register2:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.NOT,register1:register1,register2:register2,mode:.register))
        }

    //
    // DISPATCH the generic method in question
    //
    public static func DSP(address:ArgonWord,count:Int) -> VMInstruction
        {
        return(VMInstruction(.DSP,immediate:count,address:address,mode: .address))
        }
    
    //
    // PUSH register1 onto the stack
    //
    public static func PUSH(register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.PUSH,register1:register,mode: .register))
        }
    
    //
    // PUSH address onto the stack
    //
    public static func PUSH(address:ArgonWord) -> VMInstruction
        {
        return(VMInstruction(.PUSH,address:address,mode: .address))
        }
    
    //
    // PUSH immediate onto the stack
    //
    public static func PUSH(immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.PUSH,immediate:immediate,mode: .immediate))
        }
    
    //
    // PUSH contents of register1 + immediate into the stack
    //
    public static func PUSH(immediate:Int,register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.PUSH,register1:register,immediate:immediate,mode: .indirect))
        }
    
    //
    // POP register1 off the stack
    //
    public static func POP(register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.POP,register1:register,mode: .register))
        }

    //
    // INCrement contents of register1 + immediate
    //
    public static func INC(immediate:Int,register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.INC,register1:register,immediate:immediate,mode: .indirect))
        }
    
    //
    // Increment contents of register1
    //
    public static func INC(register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.POP,register1:register,mode: .register))
        }
    
    //
    // Decrement contents of register1 + immediate
    //
    public static func DEC(immediate:Int,register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.DEC,register1:register,immediate:immediate,mode: .indirect))
        }
    
    //
    // Decrement contents of register1
    //
    public static func DEC(register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.DEC,register1:register,mode: .register))
        }
    
    //
    // Call the next most specific method
    //
    public static func NXT() -> VMInstruction
        {
        return(VMInstruction(.NXT))
        }
    
    //
    // Call the operating system
    //
    public static func HALT() -> VMInstruction
        {
        return(VMInstruction(.HALT))
        }
    
    //
    // Invoke a primitive
    //
    public static func PRIM(immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.PRIM,immediate:immediate,mode:.immediate))
        }
    
    //
    // Make an instance of the specified traits
    //
    public static func MAKE(immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.MAKE,immediate:immediate,mode:.immediate))
        }
    
    //
    // Return from NXT,MKE,DSP or CALL
    //
    public static func RET() -> VMInstruction
        {
        return(VMInstruction(.RET))
        }
    
    //
    // CALL the address
    //
    public static func CALL(address:ArgonWord) -> VMInstruction
        {
        return(VMInstruction(.CALL,address:address,mode:.address))
        }
    
    //
    // Load the word at the address in the data segment into register1
    //
    public static func LOAD(address:ArgonWord,register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.LOAD,register1:register,address:address,mode:.address))
        }
    
    //
    // Load the word at the offset in the data segment defined by immediate into register1
    //
    public static func LOAD(immediate:Int,register:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.LOAD,register1:register,immediate:immediate,mode:.immediate))
        }
    
    //
    // Store the word in register1 into the data segment at offset in immediate
    //
    //
    public static func STORE(register1:VMRegister,immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.STORE,register1:register1,immediate:immediate,mode:.immediate))
        }
    
    //
    // Store the word in register1 into the data segment with address that
    // it was stored returned in register 2
    //
    //
    public static func STORE(register1:VMRegister,register2:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.STORE,register1:register1,register2:register2,mode:.register))
        }
    
    //
    // Store the word in register1 into the slot in the dataSegment
    // pointed to by address
    //
    public static func STORE(register1:VMRegister,address:ArgonWord) -> VMInstruction
        {
        return(VMInstruction(.STORE,register1:register1,address:address,mode:.address))
        }
    
    //
    // Create a new thread and execute the closure on the stack in that thread.
    // The thread runs until the closure completes execution
    //
    public static func SPAWN(address:ArgonWord) -> VMInstruction
        {
        return(VMInstruction(.SPAWN,address:address,mode:.address))
        }
    //
    // Cycle once doing nothing
    //
    public static func NOP() -> VMInstruction
        {
        return(VMInstruction(.NOP))
        }
    
    public var mode:VMInstructionMode
        {
        get
            {
            return(VMInstructionMode(rawValue: Int((instructionWord & VMInstruction.kModeMask) >> VMInstruction.kModeShift))!)
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kModeMask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kModeShift)
            }
        }
    
    public var operation:VMOperation
        {
        get
            {
            return(VMOperation(rawValue: Int((instructionWord & VMInstruction.kOperationMask) >> VMInstruction.kOperationShift))!)
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kOperationMask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kOperationShift)
            }
        }
    
    public var register1:VMRegister
        {
        get
            {
            return(VMRegister(rawValue: Int((instructionWord & VMInstruction.kRegister1Mask) >> VMInstruction.kRegister1Shift)))
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kRegister1Mask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kRegister1Shift)
            }
        }
    
    public var register2:VMRegister
        {
        get
            {
            return(VMRegister(rawValue: Int((instructionWord & VMInstruction.kRegister2Mask) >> VMInstruction.kRegister2Shift)))
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kRegister2Mask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kRegister2Shift)
            }
        }
    
    public var register3:VMRegister
        {
        get
            {
            return(VMRegister(rawValue: Int((instructionWord & VMInstruction.kRegister3Mask) >> VMInstruction.kRegister3Shift)))
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kRegister3Mask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kRegister3Shift)
            }
        }
    
    public var immediate:Int
        {
        get
            {
            var value = Int((instructionWord & VMInstruction.kImmediateMask) >> VMInstruction.kImmediateShift)
            if (instructionWord & VMInstruction.kImmediateSignMask) == VMInstruction.kImmediateSignMask
                {
                value *= -1
                }
            return(value)
            }
        set
            {
            var isNegative = false
            var value = newValue
            if value < 0
                {
                isNegative = true
                value *= -1
                }
        
            value = Int((UInt64(value) & VMInstruction.kImmediateMask) >> VMInstruction.kImmediateShift)
            if isNegative
                {
                instructionWord &= ~VMInstruction.kImmediateSignMask
                instructionWord |= (ArgonWord(1) << VMInstruction.kImmediateSignShift)
                }
            instructionWord &= ~VMInstruction.kImmediateMask
            instructionWord |= (ArgonWord(value) << VMInstruction.kImmediateShift)
            }
        }

    public var hasValidTarget:Bool
        {
        return(target != nil)
        }
    
    public var hasLabels:Bool
        {
        return(!labels.isEmpty)
        }
    
    public var isTarget:Bool
        {
        return(!labels.isEmpty)
        }
    
    public var isInlineMarker:Bool
        {
        return(false)
        }
    
    public private(set) var instructionWord:ArgonWord = 0
    public var addressWord:ArgonWord = 0
    public var labels:[String] = []
    public var target:String?
    public var comment:String?
    public var IP:Int = 0
    public var lineTrace:ArgonLineTrace?
    public var relocationLabel:String?
    
    public var instructionWords:[ArgonWord]
        {
        if self.mode == .address
            {
            return([instructionWord,addressWord])
            }
        else
            {
            return([instructionWord])
            }
        }
    
    public init(_ word:ArgonWord)
        {
        instructionWord = word
        }
    
    public init(_ operation:VMOperation)
        {
        super.init()
        self.operation = operation
        self.mode = .regular
        }
    
    public init(_ operation:VMOperation,register1:VMRegister,address:ArgonWord,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.register1 = register1
        self.addressWord = address
        }
    
   public init(_ operation:VMOperation,address:ArgonWord,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.addressWord = address
        }
    
    public init(_ operation:VMOperation,immediate:Int,address:ArgonWord,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        self.addressWord = address
        }
    
    public init(_ operation:VMOperation,register1:VMRegister,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.register1 = register1
        }
    
    public init(_ operation:VMOperation,immediate:Int,mode:VMInstructionMode = .immediate)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        }
    
    public init(_ operation:VMOperation,register1:VMRegister,immediate:Int,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        self.register1 = register1
        }
    
    public init(_ operation:VMOperation,register1:VMRegister,register2:VMRegister,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.register1 = register1
        self.register2 = register2
        }
    
    public init(_ operation:VMOperation,register1:VMRegister,register2:VMRegister,register3:VMRegister,mode:VMInstructionMode = .register)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.register1 = register1
        self.register2 = register2
        self.register3 = register3
        }
    
    public init(_ operation:VMOperation,register1:VMRegister,register2:VMRegister,immediate:Int,mode:VMInstructionMode = .immediate)
        {
        super.init()
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        self.register1 = register1
        self.register2 = register2
        }
    
    public init(_ instruction:CodingInstruction)
        {
        self.instructionWord = instruction.instructionWord
        self.addressWord = instruction.addressWord
        self.labels = instruction.labels
        self.comment = instruction.comment
        self.IP = instruction.IP
        self.lineTrace = instruction.lineTrace
        self.relocationLabel = instruction.relocationLabel
        }
    
    
    public func specialRegistersUsed() -> [MachineRegister]
        {
        var specialRegisters:[MachineRegister] = []
        var register = ((instructionWord & VMInstruction.kRegister1Mask) >> VMInstruction.kRegister1Shift)
        if  register <= 5
            {
            specialRegisters.append(MachineRegister(rawValue: Int(register))!)
            }
        register = ((instructionWord & VMInstruction.kRegister2Mask) >> VMInstruction.kRegister2Shift)
        if  register <= 5
            {
            specialRegisters.append(MachineRegister(rawValue: Int(register))!)
            }
        register = ((instructionWord & VMInstruction.kRegister3Mask) >> VMInstruction.kRegister3Shift)
        if  register <= 5
            {
            specialRegisters.append(MachineRegister(rawValue: Int(register))!)
            }
        return(specialRegisters)
        }
    
    @discardableResult
    public func wantsRelocation(of item:@escaping ArgonRelocationEntryConversion) -> VMInstruction
        {
        self.relocationLabel = "R$\(Argon.nextCounter)$"
        ArgonRelocationTable.shared.relocate(item,at: self.relocationLabel!)
        self.addressWord = 0xBADDEADBEEF
        return(self)
        }
    
    public func dump()
        {
        print(self.disassemble())
        }
    
    public func disassemble() -> String
        {
        let header = "  "
        let footer = comment ?? ""
        switch(self.mode)
            {
            case .immediate:
                if self.operation == .BRT || self.operation == .BRF
                    {
                    return("\(header) \(self.operation) \(self.register1.register) \(self.immediate) \(footer)")
                    }
                else if self.operation == .MOVIR || self.operation == .LOAD || self.operation == .STORE
                    {
                    return("\(header) \(self.operation) \(self.immediate) \(self.register1.register) \(footer)")
                    }
                else if self.operation == .PRIM || self.operation == .MAKE || self.operation == .PUSH || self.operation == .BR
                    {
                    if self.immediate == 0 && self.operation == .BR
                        {
                        return("BR TARGET WAS \(self.target!)")
                        }
                    return("\(header) \(self.operation) \(self.immediate) \(footer)")
                    }
                else
                    {
                    return("\(header) \(self.operation) \(self.immediate) \(self.register1.register) \(footer)")
                    }
            case .register:
                let register1Text = self.register1.register == .NONE ? "" : "\(self.register1.register) \(footer)"
                let register2Text = self.register2.register == .NONE ? "" : "\(self.register2.register) \(footer)"
                let register3Text = self.register3.register == .NONE ? "" : "\(self.register3.register) \(footer)"
                if self.operation == .MOVRR
                    {
                    return("\(header) \(self.operation) \(register1Text) \(register2Text) \(footer)")
                    }
                else if self.operation == .PUSH || self.operation == .POP || self.operation == .INC || self.operation == .DEC
                    {
                    return("\(header) \(self.operation) \(register1Text) \(footer)")
                    }
                else
                    {
                    return("\(header) \(self.operation) \(register1Text) \(register2Text) \(register3Text)")
                    }
            case .leftIndirect:
                let immediateString = self.immediate < 0 ? "\(self.immediate)" : "+\(self.immediate)"
                return("\(header) \(self.operation) [\(self.register1.register)\(immediateString)] \(self.register2.register) \(footer)")
            case .rightIndirect:
                let immediateString = self.immediate < 0 ? "\(self.immediate)" : "+\(self.immediate)"
                return("\(header) \(self.operation) \(self.register1.register) [\(self.register2.register)\(immediateString)] \(footer)")
            case .address:
                let addressString = String(format: "0x%08X",self.addressWord)
                if self.operation == .MOVAR
                    {
                    return("\(header) \(self.operation) \(addressString) \(self.register1.register) \(footer)")
                    }
                else if self.operation == .DSP
                    {
                    return("\(header) \(self.operation) \(addressString) \(self.immediate) \(footer)")
                    }
                else if self.operation == .PUSH || self.operation == .CALL
                    {
                    return("\(header) \(self.operation) \(addressString) \(footer)")
                    }
                else if self.operation == .STORE
                    {
                    return("\(header) \(self.operation) \(register1.register) \(addressString) \(footer)")
                    }
                else
                    {
                    return("\(header) \(self.operation) \(addressString) \(self.register1.register) \(footer)")
                    }
            case .indirect:
                let immediateString = self.immediate < 0 ? "\(self.immediate)" : "+\(self.immediate)"
                if self.operation == .PUSH || self.operation == .INC || self.operation == .DEC
                    {
                    return("\(header) \(self.operation) [\(self.register1.register)\(immediateString)] \(footer)")
                    }
                else
                    {
                    return("\(header) \(self.operation) [\(self.register1.register)\(immediateString)] \(footer)")
                    }
            case .regular:
                return("\(header) \(self.operation) \(footer)")
            default:
                break
            }
        return("ERROR DISASSEMBLING")
        }
    }
    
public class CodingInstruction:NSObject,NSCoding
    {
    public private(set) var instructionWord:ArgonWord = 0
    public var addressWord:ArgonWord = 0
    public var labels:[String] = []
    public var target:String?
    public var comment:String?
    public var IP:Int = 0
    public var lineTrace:ArgonLineTrace?
    public var relocationLabel:String?
    
    public init(_ instruction:VMInstruction)
        {
        self.instructionWord = instruction.instructionWord
        self.addressWord = instruction.addressWord
        self.labels = instruction.labels
        self.comment = instruction.comment
        self.IP = instruction.IP
        self.lineTrace = instruction.lineTrace
        self.relocationLabel = instruction.relocationLabel
        }
    
    public func encode(with aCoder: NSCoder)
        {
        var word = NSNumber(value: instructionWord)
        aCoder.encode(word,forKey:"instructionWord")
        word = NSNumber(value: addressWord)
        aCoder.encode(word,forKey:"addressWord")
        aCoder.encode(labels,forKey:"labels")
        if let relocLabel = self.relocationLabel
            {
            aCoder.encode(relocLabel,forKey:"relocationLabel")
            }
        if let aTarget = target
            {
            aCoder.encode(aTarget,forKey:"target")
            }
        if let aComment = comment
            {
            aCoder.encode(aComment,forKey:"comment")
            }
        aCoder.encode(IP,forKey:"IP")
        if let aLineTrace = lineTrace
            {
            aCoder.encode(aLineTrace,forKey:"lineTrace")
            }
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        var word = aDecoder.decodeObject(forKey: "instructionWord") as! NSNumber
        instructionWord = word.uint64Value
        word = aDecoder.decodeObject(forKey: "addressWord") as! NSNumber
        addressWord = word.uint64Value
        labels = aDecoder.decodeObject(forKey: "labels") as! [String]
        target = aDecoder.decodeObject(forKey: "target") as? String
        comment = aDecoder.decodeObject(forKey: "comment") as? String
        IP = aDecoder.decodeInteger(forKey: "IP")
        lineTrace = aDecoder.decodeObject(forKey: "lineTrace") as? ArgonLineTrace
        relocationLabel = aDecoder.decodeObject(forKey: "relocationLabel") as? String
        super.init()
        }
    }

public class VMInlineMarkerInstruction:VMInstruction
    {
    public private(set) var genericMethodId:Int

    public override var isInlineMarker:Bool
        {
        return(false)
        }
    
    public init(methodId:Int)
        {
        self.genericMethodId = methodId
        super.init(0)
        }
    }
