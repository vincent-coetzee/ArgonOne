//
//  ThreeAddressInstruction.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ThreeAddressVariableLiveness
    {
    weak var nextUse:ThreeAddressInstruction?
    var isAlive = false
    
    init(alive:Bool,next:ThreeAddressInstruction?)
        {
        isAlive = alive
        nextUse = next
        }
    }

public class ThreeAddressInstruction
    {
    public enum InstructionType
        {
        case leader
        case regular
        }
    
    var stackFrameNumber:Int?
    var label:String?
    var comment:String?
    let lhs:ThreeAddress?
    let operand1:ThreeAddress?
    var operand2:ThreeAddress?
    let operation:ThreeAddressOperation
    var target:ThreeAddressTarget = .none
        {
        didSet
            {
            if target.isAddress
                {
                operand2 = target.targetIP
                }
            }
        }
    
    var IP = -1
    var instructionType = InstructionType.regular
    var lhsLiveness:ThreeAddressVariableLiveness?
    var operand1Liveness:ThreeAddressVariableLiveness?
    var operand2Liveness:ThreeAddressVariableLiveness?
    var lineTrace:ArgonLineTrace?
    
    public var variablesUsed:[ArgonVariableNode]
        {
        var variables:[ArgonVariableNode] = []
        
        if let aLhs = lhs,aLhs.isVariable
            {
            variables.append(aLhs as! ArgonVariableNode)
            }
        if let anOperand1 = operand1,anOperand1.isVariable
            {
            variables.append(anOperand1 as! ArgonVariableNode)
            }
        if let anOperand2 = operand2,anOperand2.isVariable
            {
            variables.append(anOperand2 as! ArgonVariableNode)
            }
        return(variables)
        }
    
    public var hasValidTarget:Bool
        {
        return(target != .none)
        }
    
    public var isTarget:Bool
        {
        return(label != nil)
        }
    
    public var hasOperands:Bool
        {
        return(operand1 != nil || operand2 != nil)
        }
    
    public var isDirectAssignment:Bool
        {
        return(lhs != nil && operand1 != nil && operation == .assign)
        }
    
    public var isJump:Bool
        {
        return(operation.isJump)
        }
    
    public var isJumpWithOperand:Bool
        {
        return(operation.isJumpWithOperand)
        }
    
    public var isJumpWithoutOperand:Bool
        {
        return(operation.isJumpWithoutOperand)
        }
    
    public var isCall:Bool
        {
        return(operation == .dispatch || operation == .call)
        }
    
    public var targetIP:Int
        {
        let offset = target.targetIP
        let newIP = IP + offset
        return(newIP)
        }
    
    init()
        {
        self.operand1 = nil
        self.operand2 = nil
        self.operation = .none
        self.lhs = nil
        }
    
    init(operand1:ThreeAddress,operation:ThreeAddressOperation,operand2:ThreeAddress,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.operand1 = operand1
        self.operand2 = nil
        self.operation = operation
        self.lhs = nil
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(lhs:ThreeAddress,operation:ThreeAddressOperation,operand1:ThreeAddress,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = lhs
        self.operand1 = operand1
        self.operand2 = nil
        self.operation = operation
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(lhs:ThreeAddress,operand1:ThreeAddress?,operation:ThreeAddressOperation,operand2:ThreeAddress?,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = lhs
        self.operand1 = operand1
        self.operand2 = operand2
        self.operation = operation
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(operation:ThreeAddressOperation,target:String,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = nil
        self.operand1 = nil
        self.operand2 = nil
        self.operation = operation
        self.target = .label(target)
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(operation:ThreeAddressOperation,target:ThreeAddress,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = nil
        self.operand1 = nil
        self.operand2 = nil
        self.operation = operation
        self.target = .threeAddress(target)
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(lhs:ThreeAddress,operation:ThreeAddressOperation,target:ThreeAddress,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = lhs
        self.operand1 = nil
        self.operand2 = nil
        self.operation = operation
        self.target = .threeAddress(target)
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(operation:ThreeAddressOperation,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = nil
        self.operand1 = nil
        self.operand2 = nil
        self.operation = operation
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(operand1:ThreeAddress,operation:ThreeAddressOperation,target:String,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = nil
        self.operand1 = operand1
        self.operand2 = nil
        self.operation = operation
        self.target = .label(target)
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    init(operation:ThreeAddressOperation,operand1:ThreeAddress,comment:String? = nil,stackFrameNumber:Int? = nil)
        {
        self.lhs = nil
        self.operand1 = operand1
        self.operand2 = nil
        self.operation = operation
        self.comment = comment
        self.stackFrameNumber = stackFrameNumber
        }
    
    func dump()
        {
        print(label != nil && IP >= 0 ? String(format: "%06d ",IP) : (label == nil ? "       " : label!),terminator:"")
        if operation.isJumpWithOperand
            {
            if target.isAddress
                {
                print("\(operand1!.name) \(operation) \(target.targetIP) = \(IP + target.targetIP)",terminator:"")
                }
            else if target.isBasicBlock
                {
                print("\(operand1!.name) \(operation) \(operand2!)",terminator:"")
                }
            else
                {
                print("\(operand1!.name) \(operation) \(target.targetName)",terminator:"")
                }
            }
        else if operation.isJumpWithoutOperand
            {
            if target.isAddress
                {
                print("\(operation) \(target.targetIP) = \(IP + target.targetIP)",terminator:"")
                }
            else if target.isBasicBlock
                {
                print("\(operation) \(operand2!)",terminator:"")
                }
            else
                {
                print("\(operation) \(target.targetName)",terminator:"")
                }
            }
        else if operation == .make
            {
            print("\(lhs!.name) = \(operation) \(operand2!.name)",terminator:"")
            }
        else if operation == .dispatch
            {
            print("\(lhs!.name) = \(operation) \(operand1!.name) \(operand2!.name)",terminator:"")
            }
        else if operation == .call
            {
            if lhs == nil
                {
                print("\(operation) \(target.threeAddressName)",terminator:"")
                }
            else
                {
                print("\(lhs!.name) = \(operation) \(target.threeAddressName)",terminator:"")
                }
            }
        else if operation == .assign
            {
            print("\(lhs!.name) = \(operand1!.name)",terminator:"")
            }
        else if operation == .param || operation == .return || operation == .enter || operation == .leave || operation == .prim || operation == .spawn || operation == .clear
            {
            print("\(operation) \(operand1!.name)",terminator:"")
            }
        else if operation == .halt || operation == .nop || operation == .ret
            {
            print("\(operation)",terminator:"")
            }
        else
            {
            print("\(lhs!.name) = \(operand1!.name) \(operation) \(operand2!.name)",terminator:"")
            }
        let commentString = comment ?? ""
        print("\t\t\t\(commentString)")
        }
    }
