//
//  ArgonCodeContainer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa
import Foundation
import Swift

public class ThreeAddressOptimizer
    {
    public var instructions:[ThreeAddressInstruction] = []
    public var basicBlocks:[ThreeAddressBasicBlock] = []
    public var blocksByIP:[Int:ThreeAddressBasicBlock] = [:]
    
    public var startIndex:Int
        {
        return(instructions.startIndex)
        }
    
    public var endIndex:Int
        {
        return(instructions.endIndex)
        }
    
    public func index(after:Int) -> Int
        {
        return(instructions.index(after: after))
        }
    
    public subscript(_ index:Int) -> ThreeAddressInstruction
        {
        return(instructions[index])
        }
    
    public var lastLHS:ThreeAddress
        {
        return(instructions.last!.lhs!)
        }

    public func add(_ instruction:ThreeAddressInstruction)
        {
        instructions.append(instruction)
        }
    
    public func dump()
        {
        for instruction in instructions
            {
            instruction.dump()
            }
        }
    
    public func performNextUseAndLivenessAnalysis(using symbolTable: ArgonSymbolTable) throws
        {
        for block in basicBlocks
            {
            let variables = block.variablesTouched()
            for node in variables
                {
                node.symbolTableEntry!.isAlive = true
                node.symbolTableEntry!.nextUseInstruction = nil
                }
            for instruction in block.instructions.reversed()
                {
                if let lhs = instruction.lhs,lhs.isVariable,let lhsValue = lhs as? ArgonVariableNode
                    {
                    instruction.lhsLiveness = ThreeAddressVariableLiveness(alive: lhsValue.symbolTableEntry!.isAlive,next: nil)
                    lhsValue.symbolTableEntry!.isAlive = false
                    lhsValue.symbolTableEntry!.nextUseInstruction = nil
                    }
                if let operand1 = instruction.operand1,operand1.isVariable,let operand1Value = operand1 as? ArgonVariableNode
                    {
                    instruction.operand1Liveness = ThreeAddressVariableLiveness(alive: operand1Value.symbolTableEntry!.isAlive,next: nil)
                    operand1Value.symbolTableEntry!.isAlive = true
                    operand1Value.symbolTableEntry!.nextUseInstruction = instruction
                    }
                if let operand2 = instruction.operand2,operand2.isVariable,let operand2Value = operand2 as? ArgonVariableNode
                    {
                    instruction.operand2Liveness = ThreeAddressVariableLiveness(alive: operand2Value.symbolTableEntry!.isAlive,next: nil)
                    operand2Value.symbolTableEntry!.isAlive = true
                    operand2Value.symbolTableEntry!.nextUseInstruction = instruction
                    }
                }
            }
        }
    
    public func dumpBasicBlocks()
        {
        for block in basicBlocks
            {
            print("BLOCK \(block.key)==================================")
            for instruction in block.instructions
                {
                instruction.dump()
                }
            }
        }
    
    public func fixupTargets() throws
        {
        var callers:[String:[ThreeAddressInstruction]] = [:]
        var targets:[String:ThreeAddressInstruction] = [:]
        
        var IP = 0
        for instruction in instructions
            {
            instruction.IP = IP
            if instruction.hasValidTarget
                {
                var array = callers[instruction.target.targetLabel]
                if array == nil
                    {
                    array = [instruction]
                    }
                else
                    {
                    array!.append(instruction)
                    }
                callers[instruction.target.targetLabel] = array!
                }
            if instruction.isTarget
                {
                targets[instruction.label!] = instruction
                }
            IP += 8
            }
        for callerValues in callers.values
            {
            for caller in callerValues
                {
                caller.target = .address(targets[caller.target.targetLabel]!.IP - caller.IP)
                }
            }
        }
    
    public func constructFlowGraph() throws
        {
        if basicBlocks.isEmpty
            {
            throw(CompilerError.noBasicBlocks)
            }
        var lastBlock:ThreeAddressBasicBlock?
        for block in basicBlocks
            {
            if block.lastInstructionIsJump
                {
                let targetIP = block.lastInstruction.targetIP
                let targetBlock = blocksByIP[targetIP]!
                block.lastInstruction.target = .basicBlock(targetBlock)
                let edge = ThreeAddressControlFlowEdge(from: block,to: targetBlock)
                edge.setNodeEdges()
                }
            else if lastBlock != nil && !lastBlock!.lastInstructionIsJump
                {
                let edge = ThreeAddressControlFlowEdge(from: lastBlock!,to: block)
                edge.setNodeEdges()
                }
            lastBlock = block
            }
        }
    
    public func constructBasicBlocks() throws
        {
        guard instructions.count > 0 else
            {
            throw(CompilerError.noThreeAddressInstructions)
            }
        var lastWasJump = false
        instructions.first!.instructionType = .leader
        for instruction in instructions
            {
            if instruction.isTarget
                {
                instruction.instructionType = .leader
                }
            if lastWasJump
                {
                instruction.instructionType = .leader
                lastWasJump = false
                }
            if instruction.isJump || instruction.isCall
                {
                lastWasJump = true
                }
            }
        var currentBlock:ThreeAddressBasicBlock? = nil
        for instruction in instructions
            {
            if instruction.instructionType == .leader
                {
                let newBlock = ThreeAddressBasicBlock(instructions:[instruction])
                blocksByIP[instruction.IP] = newBlock
                basicBlocks.append(newBlock)
                currentBlock = newBlock
                }
            else
                {
                currentBlock?.append(instruction)
                }
            }
        }
    
    public func constructDAGs()
        {
        for block in basicBlocks
            {
            block.constructDAG()
            block.blockDAG.splitCommonSubexpressions()
            assert(!block.blockDAG.hasCommonSubexpression,"DAG SHOULD NOT HAVE ANY COMMON SUBEXPRESSIONS")
            block.blockDAG.labelWithRequiredRegisterCount()
            }
        }
    }
