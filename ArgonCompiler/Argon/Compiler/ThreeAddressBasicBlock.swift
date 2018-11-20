//
//  ThreeAddressBasicBlock.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ThreeAddressBasicBlock:Equatable
    {
    public var blockDAG = BasicBlockDAG()
    public var internalName:String?
    public var extername:String?
    
    public static func ==(lhs:ThreeAddressBasicBlock,rhs:ThreeAddressBasicBlock) -> Bool
        {
        return(lhs.key == rhs.key)
        }
    
    internal var instructions:[ThreeAddressInstruction] = []
    public var incomingEdges:[ThreeAddressControlFlowEdge] = []
    public var outgoingEdge:ThreeAddressControlFlowEdge?
    internal var key:Int = 0
    
    public var lastInstruction:ThreeAddressInstruction
        {
        return(instructions.last!)
        }
    
    public var lastInstructionIsJump:Bool
        {
        return(self.lastInstruction.operation.isJump)
        }
    
    init(instructions:[ThreeAddressInstruction])
        {
        self.key = Argon.nextCounter
        self.instructions = instructions
        }
    
    init()
        {
        self.key = Argon.nextCounter
        }
    
    func append(_ instruction:ThreeAddressInstruction)
        {
        instructions.append(instruction)
        }
    
    func variablesTouched() -> [ArgonVariableNode]
        {
        var variables:[ArgonVariableNode] = []
        for instruction in instructions
            {
            variables.append(contentsOf: instruction.variablesUsed)
            }
        return(variables)
        }
    
    func constructDAG()
        {
        guard instructions.count > 0 else
            {
            return
            }
        for instruction in instructions
            {
            let operation = instruction.operation
            if instruction.isDirectAssignment
                {
                let name = instruction.operand1!.name.string
                var nodeM:BasicBlockDAG.Node
                let node = blockDAG.node(with: name)
                if node == nil
                    {
                    nodeM = BasicBlockDAG.LeafNode(name)
                    }
                else
                    {
                    nodeM = node!
                    }
                let newNode = BasicBlockDAG.InnerNode(.assign,nodeM,nil)
                blockDAG.add(node: newNode)
                let label = instruction.lhs!.name.string
                if let nodeP = blockDAG.node(with: label)
                    {
                    nodeP.remove(label: label)
                    }
                newNode.add(label: label)
                }
            else if instruction.hasOperands
                {
                let lhs = instruction.operand1 != nil ? blockDAG.operand(for: instruction.operand1!) : nil
                let rhs = instruction.operand2 != nil ? blockDAG.operand(for: instruction.operand2!) : nil
                var node:BasicBlockDAG.InnerNode?
                node = blockDAG.inner(for: operation,lhs,rhs)
                if node == nil
                    {
                    node = BasicBlockDAG.InnerNode(operation,lhs,rhs)
                    blockDAG.add(node: node!)
                    }
                if instruction.lhs != nil
                    {
                    let label = instruction.lhs!.name.string
                    let nodeP = blockDAG.node(with: label)
                    nodeP?.remove(label: label)
                    node?.add(label: label)
                    }
                }
            else
                {
                blockDAG.add(node: BasicBlockDAG.InnerNode(instruction.operation,nil,nil))
                }
            }
        }
    }

