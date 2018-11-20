//
//  ArgonCompiler3AddressPass.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class ThreeAddressPass
    {
    private var pendingLabel:String?
    private var currentContainer:ArgonCodeContainer?
    private var containers:[ArgonCodeContainer] = []
    public private(set) var topLevelContainer:ArgonCodeContainer!
    private var pendingLineTrace:ArgonLineTrace?
    
    public func setTopLevelContainer(_ top:ArgonCodeContainer)
        {
        topLevelContainer = top
        }
    
    public func newTemporary() -> ArgonTemporaryVariableNode
        {
        let temp = ArgonTemporaryVariableNode(name:ArgonName("$\(Argon.nextCounter)"))
        return(temp)
        }
    
    public func newLabel() -> String
        {
        let label = String(format:"L%05d:",Argon.nextCounter)
        return(label)
        }
    
    public func pass(over module: ArgonCompilationUnit) throws
        {
        try module.threeAddress(pass: self)
        }
    
    public func labelNextInstruction(with label:String)
        {
        pendingLabel = label
        }
    
    public func lastLHS() -> ThreeAddress
        {
        return(currentContainer!.lastLHS)
        }
    
    public func add(_ instruction:ThreeAddressInstruction) -> Int
        {
        if pendingLabel != nil
            {
            instruction.label = pendingLabel!
            pendingLabel = nil
            }
        if pendingLineTrace != nil
            {
            instruction.lineTrace = pendingLineTrace!
            pendingLineTrace = nil
            }
        return(currentContainer!.add(instruction))
        }
    
    public func addLineTraceToNextStatement(lineTrace:ArgonLineTrace)
        {
        pendingLineTrace = lineTrace
        }
    
    public func pushContainer(_ container:ArgonCodeContainer)
        {
        if currentContainer != nil
            {
            containers.append(currentContainer!)
            }
        currentContainer = container
        }
    
    @discardableResult
    public func popContainer() -> ArgonCodeContainer?
        {
        if pendingLabel != nil
            {
            self.add(ThreeAddressInstruction(operation: .nop))
            }
        let oldContainer = currentContainer
        currentContainer = containers.popLast()
        return(oldContainer)
        }
    
    @discardableResult
    public func generateCode(_ codeContainers:[ArgonCodeContainer]) throws -> ThreeAddressCodeGenerator
        {
        let generator = ThreeAddressCodeGenerator()
        for container in codeContainers
            {
            generator.reset()
            try container.generateCode(with: generator)
            }
        return(generator)
        }
    
    public func fixupTargets(_ codeContainers:[ArgonCodeContainer]) throws
        {
        for container in codeContainers
            {
            try container.fixupTargets()
            }
        for container in codeContainers
            {
            for instruction in container.instructionList
                {
                if instruction.operation == .BR || instruction.operation == .BRF || instruction.operation == .BRT
                    {
                    if instruction.immediate == 0
                        {
                        print("ERROR IN BRANCH INSTRUCTION AFTER FIXUP, DELTA IS 0")
                        print(container)
                        instruction.dump()
                        }
                    }
                }
            }
        }
    
    public func dumpBasicBlocks()
        {
        }
    
    public func constructFlowGraph() throws
        {
        }
    
    public func constructBasicBlocks() throws
        {
        }
    
    public func performNextUseAndLivenessAnalysis(using symbolTable: ArgonSymbolTable) throws
        {
        }
    
    public func constructDAGs()
        {
        }
    
    public func peepholeOptimize(_ codeContainers:[ArgonCodeContainer]) throws
        {
        let optimizer = ArgonPeepholeOptimizer()
        for container in codeContainers
            {
            try container.peepholeOptimize(using: optimizer)
            }
        }
    
    public func dump()
        {
        topLevelContainer.dump()
        }

    }
