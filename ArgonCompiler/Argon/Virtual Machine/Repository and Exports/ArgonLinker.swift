//
//  ArgonLinker.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/10.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonLinker
    {
    public private(set) var vm:VirtualMachine?
    public private(set) var memory:Memory?
//    private var methodsByName:[String:Pointer] = [:]
    public private(set) var relocations:ArgonRelocationTable = ArgonRelocationTable()
    private var relocationEntriesByLabel:[String:ArgonRelocationTableEntry] = [:]
    public var packageSizeInBytes:Int = 0
    public private(set) var module:ArgonModule?
    public private(set) var traitsCount:Int = 0
    public private(set) var methodCount:Int = 0
    public private(set) var closureCount:Int = 0
    
    public init()
        {
        }
    
    private func catalogue(traits input: [ArgonTraits]) throws
        {
        for traits in ArgonTraits.orderTraitsByInheritance(input)
            {
            if !traits.isInstalled
                {
                print("FINDING TRAITS \(traits.fullName)")
                let parents = traits.parents.map{$0.pointer}
                if let aTrait = try memory!.traits(atName: traits.fullName)
                    {
                    traits.pointer = aTrait
                    }
                else
                    {
                    let memorySlotLayouts = traits.slotLayouts.values.map{MemorySlotLayout($0.name,$0.offsetInInstance,$0.traits.pointer)}
                    traits.pointer = try memory!.allocate(traitsNamed: traits.fullName, slots: memorySlotLayouts, parents: parents)
                    try memory!.setTraits(traits.pointer, atName: traits.fullName)
                    }
                traits.isInstalled = true
                }
            }
        }
    
    private func catalogue(entries: [ArgonRelocationTableEntry]) throws
        {
        for entry in entries
            {
            if entry.labels.count > 0
                {
                for label in entry.labels
                    {
                    relocationEntriesByLabel[label] = entry
                    }
                }
            }
        }
    
    public func relocate(codeBlock:ArgonCodeBlock)
        {
        let instructionsByLabel = codeBlock.instructionsWantingRelocation
        for instruction in instructionsByLabel.values
            {
            let label = instruction.relocationLabel!
            let entry = self.relocationEntriesByLabel[label]!
            switch(entry.kind)
                {
                case .string:
                    instruction.addressWord = pointerAsWord(entry.string.pointer)
                case .symbol:
                    instruction.addressWord = pointerAsWord(entry.symbol.pointer)
                case .closure:
                    instruction.addressWord = pointerAsWord(entry.closure.pointer)
                case .genericMethod:
                    instruction.addressWord = pointerAsWord(entry.genericMethod.pointer)
                case .traits:
                    instruction.addressWord = pointerAsWord(entry.traits.pointer)
                case .global:
                    instruction.addressWord = pointerAsWord(entry.global.pointer)
                default:
                    break
                }
            }
        }
    
    private func installModuleParts(executable:ArgonExecutable) throws
        {
        let pointer = try self.memory!.allocate(codeBlock:executable.entryPoint.instructions)
        let codeBlock = CodeBlockPointerWrapper(pointer)
        codeBlock.runnable = true
        vm!.memory.add(root: pointer)
        executable.entryPointCodePointer = pointer
        }
    
    
    private func relocate(executable:ArgonExecutable) throws
        {
        self.relocate(codeBlock: executable.entryPoint)
        executable.entryPoint.dump()
        self.relocate(codeBlock: executable.executableInit)
        var closures:[ArgonClosure] = []
        for entry in self.relocations.entries
            {
            if entry.kind == .closure
                {
                let closure = entry.closure
                if !closures.contains(closure)
                    {
                    closures.append(closure)
                    }
                }
            }
        for closure in closures
            {
            self.relocate(codeBlock: closure.code)
            closure.code.dump()
            }
        }
    
    public func linkedPackage() -> ArgonLinkedPackage
        {
        return(ArgonLinkedPackage(linker: self))
        }
    
    public func link(library:ArgonLibrary) throws
        {
        }
    
    private func installCodeBlocks(executable:ArgonExecutable) throws
        {
        for entry in executable.relocations.entries
            {
            switch(entry.kind)
                {
                case .closure:
                    let closurePointer = ClosurePointerWrapper(entry.closure.pointer)
                    closurePointer.codeBlockPointer = try self.memory!.allocate(codeBlock:entry.closure.code.instructions)
                    CodeBlockPointerWrapper(closurePointer.codeBlockPointer).runnable = false
                case .genericMethod:
                    for instance in entry.genericMethod.instances
                        {
                        MethodPointerWrapper(instance.pointer).codeBlockPointer = try self.memory!.allocate(codeBlock:instance.code.instructions)
                        CodeBlockPointerWrapper(MethodPointerWrapper(instance.pointer).codeBlockPointer).runnable = false
                        }
                default:
                    break
                }
            }
        }
    
    private func installRelocatables(executable:ArgonExecutable) throws
        {
        for entry in executable.relocations.entries
            {
            switch(entry.kind)
                {
                case .string:
                    entry.string.pointer = try memory!.allocate(string: entry.string.string)
                case .symbol:
                    entry.symbol.pointer = try memory!.allocate(string: entry.symbol.string)
                case .closure:
                    closureCount += 1
                    if !entry.closure.isInstalled
                        {
                        entry.closure.pointer = try memory!.allocate(closureWithVariableCount: entry.closure.inductionVariables.count)
                        entry.closure.isInstalled = true
                        }
                case .genericMethod:
                    self.methodCount += 1
                    let method = entry.genericMethod
                    if try !method.isInstalled && memory!.method(atName: method.fullName) == nil
                        {
                        print("Installing Generic Method \(method.name)")
                        for instance in method.instances
                            {
                            print("Installing instance \(instance.name)")
                            try instance.updateParameters(from: vm!.memory!)
                            instance.pointer = try memory!.allocate(methodNamed: method.name, parameterCount: instance.parameters.count)
                            let methodPointer = MethodPointerWrapper(instance.pointer)
                            methodPointer.codeBlock = CodeBlockPointerWrapper(try self.memory!.allocate(codeBlock:instance.code.instructions))
                            print("Installed \(methodPointer.codeBlock.instructionCount) instructions")
                            }
                        try method.buildDispatchTree()
                        method.pointer = try memory!.allocate(genericMethodNamed: method.name, parameterCount: method.parameterCount, selectionTreeRoot: method.selectionTreeRoot)
                        try self.memory!.setMethod(method.pointer, atName: method.fullName)
                        method.isInstalled = true
                        }
                case .traits:
                    self.traitsCount += 1
                    let traits = entry.traits
                    if let pointer = try self.memory!.traits(atName: traits.fullName)
                        {
                        traits.pointer = pointer
                        }
                    else
                        {
                        print("ERROR - Found traits \(traits.fullName) in the relocation entries that has not already been added")
                        throw(LinkerError.relocationTraitsNotInstalled)
                        }
                case .global:
                    let global = entry.global
                    if !global.isInstalled
                        {
                        global.pointer = addressOfNextFreeWordsOfSizeInDataSegment(Int32(MemoryLayout<ArgonWord>.size),memory!.dataSegment)
                        global.isInstalled = true
                        }
                default:
                    break
                }
            }
        }
    
    public func link(executable:ArgonExecutable,into vm:VirtualMachine) throws
        {
        self.vm = vm
        self.memory = vm.memory
        self.relocations = executable.relocations
        try self.catalogue(traits: Array(executable.traits.values))
        try self.catalogue(entries: executable.relocations.entries)
        try self.installRelocatables(executable: executable)
        try self.relocate(executable: executable)
        try self.installModuleParts(executable: executable)
        try self.installCodeBlocks(executable: executable)
        self.module = executable
        }
    }
