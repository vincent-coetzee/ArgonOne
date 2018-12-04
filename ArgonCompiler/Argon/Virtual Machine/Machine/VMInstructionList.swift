//
//  VMInstructionList.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/05.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class VMInstructionSelection:Collection
    {
    private var lines:[VMInstruction] = []
    
    public var startIndex:Int
        {
        return(lines.startIndex)
        }
    
    public var endIndex:Int
        {
        return(lines.endIndex)
        }
    
    public func append(_ line:VMInstruction)
        {
        lines.append(line)
        }
    
    public func index(after:Int) -> Int
        {
        return(lines.index(after:after))
        }
    
    public subscript(_ index:Int) -> VMInstruction
        {
        return(lines[index])
        }
    }

public class VMInstructionList:Collection,FileWritable
    {
    public private(set) var instructions:[VMInstruction] = []
    private var selectedIndex:Int = 0
    private var selectedCount:Int = 0
    
    public var hasLabels:Bool
        {
        for line in instructions
            {
            if line.hasLabels
                {
                return(true)
                }
            }
        return(false)
        }
    
    public var count:Int
        {
        return(instructions.count)
        }
    
    public var startIndex:Int
        {
        return(instructions.startIndex)
        }
    
    public var endIndex:Int
        {
        return(instructions.endIndex)
        }
    
    public init()
        {
        }
        
    public init(_ instructions:[VMInstruction])
        {
        self.instructions = instructions
        }
    
    required public init(archiver: CArchiver) throws
        {
        self.instructions = []
        var count:Int = 0
        fread(&count,MemoryLayout<Int>.size,1,archiver.file)
        for _ in 0..<count
            {
            let instruction = try VMInstruction(archiver: archiver)
            instructions.append(instruction)
            }
        }
    
    public func write(archiver: CArchiver) throws
        {
        var count:Int
        count = instructions.count
        fwrite(&count,MemoryLayout<Int>.size,1,archiver.file)
        for instruction in instructions
            {
            try instruction.write(archiver: archiver)
            }
        }
    
    public func setSelection(index:Int,count:Int)
        {
        self.selectedIndex = index
        self.selectedCount = count
        }
    
    public func ableToSelectInstructions(at:Int,count:Int) -> Bool
        {
        return(at + count < instructions.count)
        }
    
    public func selectedInstruction(at index:Int) -> VMInstruction
        {
        return(instructions[selectedIndex+index])
        }
    
    public func selectedInstructions() -> [VMInstruction]
        {
        return(Array(instructions[selectedIndex..<selectedIndex+selectedCount]))
        }
    
    public func dump()
        {
        for instruction in instructions
            {
            instruction.dump()
            }
        }
    
    public func findInlineInstructions() -> VMInstructionList
        {
        return(VMInstructionList(instructions.filter{$0.isInlineMarker}))
        }
    
    public func insert(instructions newList:VMInstructionList,at index:Int)
        {
        instructions.insert(contentsOf: newList.instructions,at: index)
        }
    
    public func fixupTargets()
        {
        var callers:[String:[VMInstruction]] = [:]
        var targets:[String:VMInstruction] = [:]
        
        var IP = 0
        for instruction in instructions
            {
            instruction.IP = IP
            instruction.lineTrace?.IP = IP
            if instruction.hasValidTarget
                {
                var array = callers[instruction.target!]
                if array == nil
                    {
                    array = [instruction]
                    }
                else
                    {
                    array!.append(instruction)
                    }
                callers[instruction.target!] = array!
                }
            if instruction.isTarget
                {
                for label in instruction.labels
                    {
                    targets[label] = instruction
                    }
                }
            IP += 1
            if instruction.mode == .address
                {
                IP += 1
                }
            }
        for callerValues in callers.values
            {
            for caller in callerValues
                {
                caller.immediate = targets[caller.target!]!.IP - caller.IP - 1
                }
            }
        }
    
    public func replaceSelectedInstructions(with:[VMInstruction])
        {
        var labels:[String] = []
        for _ in selectedIndex..<selectedIndex+selectedCount
            {
            let instruction = instructions[self.selectedIndex]
            if instruction.hasLabels
                {
                labels.append(contentsOf: instruction.labels)
                }
            instructions.remove(at: selectedIndex)
            }
        for index in selectedIndex..<selectedIndex + with.count
            {
            instructions.insert(with[index-selectedIndex],at: index)
            }
        if with.count > 0 && labels.count > 0
            {
            with[0].labels = labels
            }
        else if labels.count > 0
            {
            instructions[selectedIndex+1].labels = labels
            }
        }
    
    public func index(after:Int) -> Int
        {
        return(instructions.index(after:after))
        }
    
    public subscript(_ index:Int) -> VMInstruction
        {
        return(instructions[index])
        }
    }
