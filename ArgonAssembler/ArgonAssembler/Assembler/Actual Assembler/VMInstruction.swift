//
//  VMInstruction.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum VMRegister:Int,Codable
    {
    public static let kGPROffset = 6
    public static let kFPROffset = 38

    case NONE = 0
    case BP
    case SP
    case IP
    case TP
    case XP
    case R0
    case R1
    case R2
    case R3
    case R4
    case R5
    case R6
    case R7
    case R8
    case R9
    case R10
    case R11
    case R12
    case R13
    case R14
    case R15
    case R16
    case R17
    case R18
    case R19
    case R20
    case R21
    case R22
    case R23
    case R24
    case R25
    case R26
    case R27
    case R28
    case R29
    case R30
    case R31
    case F0
    case F1
    case F2
    case F3
    case F4
    case F5
    case F6
    case F7
    case F8
    case F9
    case F10
    case F11
    case F12
    case F13
    case F14
    case F15
    case F16
    case F17
    case F18
    case F19
    case F20
    case F21
    case F22
    case F23
    case F24
    case F25
    case F26
    case F27
    case F28
    case F29
    case F30
    case F31
    
    public var name:String
        {
        switch(self)
            {
            case .NONE:
                return("NONE")
            case .BP:
                return("%BP")
            case .SP:
                return("%SP")
            case .IP:
                return("%IP")
            default:
                return("%\(self.rawValue-1)")
            }
        }
    }

public struct VMInstruction
    {
    public static let kReservedMask = ArgonWord(15) << ArgonWord(60)
    public static let kReservedShift = ArgonWord(60)
    public static let kModeMask = ArgonWord(127) << ArgonWord(56)
    public static let kModeShift = ArgonWord(56)
    public static let kOperationMask = ArgonWord(7) << ArgonWord(49)
    public static let kOperationShift = ArgonWord(49)
    public static let kRegister1Mask = ArgonWord(63) << ArgonWord(43)
    public static let kRegister1Shift = ArgonWord(43)
    public static let kRegister2Mask = ArgonWord(63) << ArgonWord(36)
    public static let kRegister2Shift = ArgonWord(36)
    public static let kRegister3Mask = ArgonWord(63) << ArgonWord(30)
    public static let kRegister3Shift = ArgonWord(30)
    public static let kImmediateSignMask = ArgonWord(1) << ArgonWord(29)
    public static let kImmediateSignShift = ArgonWord(29)
    public static let kImmediateMask = ArgonWord(536870911) << ArgonWord(0)
    public static let kImmediateShift = ArgonWord(0)
    
    public enum Mode:Int
        {
        case standard = 0
        case double
        case regPlusImmIndReg
        case regPlusImmInd
        case regPlusImmReg
        case regRegPlusImmInd
        case regRegRegPlusImm
        case regRegImm
        case regRegReg
        case regReg
        case reg
        case imm
        case immInd
        case immReg
        }
    
    public enum Operation:Int
        {
        case BR
        case BRG
        case BRGE
        case BE
        case BRLE
        case BRL
        case NOP
        case MOV
        case MOVH
        case MOVHS
        case MOVQ
        case MOVQS
        case MOVB
        case LD
        case LDH
        case LDHS
        case LDQ
        case LDQS
        case LDB
        case ST
        case STH
        case STQ
        case STB
        case AND
        case OR
        case XOR
        case NOT
        case ADD
        case SUB
        case MUL
        case MOD
        case DIV
        case DSP
        case LDS
        case MKE
        case PUSH
        case POP
        case ROL
        case ROR
        case RET
        
        public var name:String
            {
            switch(self)
                {
                case .BR:
                    return("BR")
                case .BRG:
                    return("BRG")
                case .BRGE:
                    return("BRGE")
                case .BE:
                    return("BE")
                case .BRLE:
                    return("BRLE")
                case .BRL:
                    return("BRL")
                case .NOP:
                    return("NOP")
                case .MOV:
                    return("MOV")
                case .MOVH:
                    return("MOVH")
                case .MOVHS:
                    return("MOVHS")
                case .MOVQ:
                    return("MOVQ")
                case .MOVQS:
                    return("MOVQS")
                case .MOVB:
                    return("MOVB")
                case .LD:
                    return("LD")
                case .LDH:
                    return("LDH")
                case .LDHS:
                    return("LDHS")
                case .LDQ:
                    return("LDQ")
                case .LDQS:
                    return("LDQS")
                case .LDB:
                    return("LDB")
                case .ST:
                    return("ST")
                case .STH:
                    return("STH")
                case .STQ:
                    return("STQ")
                case .STB:
                    return("STB")
                case .AND:
                    return("AND")
                case .OR:
                    return("OR")
                case .XOR:
                    return("XOR")
                case .NOT:
                    return("NOT")
                case .ADD:
                    return("ADD")
                case .SUB:
                    return("SUB")
                case .MUL:
                    return("MUL")
                case .MOD:
                    return("MOD")
                case .DIV:
                    return("DIV")
                case .DSP:
                    return("DSP")
                case .LDS:
                    return("LDS")
                case .MKE:
                    return("MKE")
                case .PUSH:
                    return("PUSH")
                case .POP:
                    return("POP")
                case .ROL:
                    return("ROL")
                case .ROR:
                    return("ROR")
                }
            }
        }
    
    //
    //
    // Instruction definitions
    //
    //
    
    //
    // Branch if register1 > register2 to immediate
    //
    public static func BRG(register1:VMRegister,register2:VMRegister,immediate:Int) -> VMInstruction
        {
        return(VMInstruction(.BRG,register1:register1,register2:register2,immediate:immediate,mode: .regRegImm))
        }
    
    //
    // Move immediate into register
    //
    public static func MOV(immediate:Int,into:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.MOV,register1:into,immediate:immediate,mode: .immReg))
        }
    
    //
    // Load word at [immediate + register1 +dataSegmentBase] into register2
    //
    public static func LDS(immediate:Int,register1:VMRegister,into:VMRegister) -> VMInstruction
        {
        return(VMInstruction(.BRG,register1:register1,register2:into,immediate:immediate,mode: .regPlusImmReg))
        }
    
    public private(set) var mode:Mode
        {
        get
            {
            return(Mode(rawValue: Int((instructionWord & VMInstruction.kModeMask) >> VMInstruction.kModeShift))!)
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kModeMask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kModeShift)
            }
        }
    
    public private(set) var operation:Operation
        {
        get
            {
            return(Operation(rawValue: Int((instructionWord & VMInstruction.kOperationMask) >> VMInstruction.kOperationShift))!)
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kOperationMask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kOperationShift)
            }
        }
    
    public private(set) var register1:VMRegister
        {
        get
            {
            return(VMRegister(rawValue: Int((instructionWord & VMInstruction.kRegister1Mask) >> VMInstruction.kRegister1Shift))!)
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kRegister1Mask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kRegister1Shift)
            }
        }
    
    public private(set) var register2:VMRegister
        {
        get
            {
            return(VMRegister(rawValue: Int((instructionWord & VMInstruction.kRegister2Mask) >> VMInstruction.kRegister2Shift))!)
            }
        set
            {
            let rawValue = newValue.rawValue
            instructionWord &= ~VMInstruction.kRegister2Mask
            instructionWord |= (ArgonWord(rawValue) << VMInstruction.kRegister2Shift)
            }
        }
    
    public private(set) var register3:VMRegister
        {
        get
            {
            return(VMRegister(rawValue: Int((instructionWord & VMInstruction.kRegister3Mask) >> VMInstruction.kRegister3Shift))!)
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
            instructionWord &= ~MachineInstruction.kImmediateMask
            instructionWord |= (ArgonWord(value) << VMInstruction.kImmediateShift)
            }
        }
    
    public private(set) var instructionWord:ArgonWord = 0
    
    public init(_ word:ArgonWord)
        {
        instructionWord = word
        }
    
    public init(_ operation:Operation)
        {
        self.operation = operation
        self.mode = .standard
        }
    
    public init(_ operation:Operation,register1:VMRegister,mode:Mode = .reg)
        {
        self.operation = operation
        self.mode = mode
        self.register1 = register1
        }
    
    public init(_ operation:Operation,immediate:Int,mode:Mode = .imm)
        {
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        }
    
    public init(_ operation:Operation,register1:VMRegister,immediate:Int,mode:Mode = .immReg)
        {
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        self.register1 = register1
        }
    
    public init(_ operation:Operation,register1:VMRegister,register2:VMRegister,register3:VMRegister,mode:Mode = .regRegReg)
        {
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        self.register1 = register1
        self.register2 = register2
        self.register3 = register3
        }
    
    public init(_ operation:Operation,register1:VMRegister,register2:VMRegister,immediate:Int,mode:Mode = .regRegImm)
        {
        self.operation = operation
        self.mode = mode
        self.immediate = immediate
        self.register1 = register1
        self.register2 = register2
        }
    }
