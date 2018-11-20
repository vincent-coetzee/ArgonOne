//
//  ArgonCodeBlock.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonCodeBlock:NSObject,NSCoding,Collection
    {
    public private(set) var instructions:[VMInstruction] = []
    
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
    
    public var instructionsWantingRelocation:[String:VMInstruction]
        {
        var list:[String:VMInstruction] = [:]
        for instruction in instructions
            {
            if let label = instruction.relocationLabel
                {
                list[label] = instruction
                }
            }
        return(list)
        }
    
    override init()
        {
        super.init()
        }
        
    init(_ list:[VMInstruction])
        {
        for instruction in list
            {
            instructions.append(instruction)
            }
        }
    
    init(_ instructionList:VMInstructionList)
        {
        for instruction in instructionList
            {
            instructions.append(instruction)
            }
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(instructions.map{CodingInstruction($0)},forKey:"instructions")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        let codingInstructions = aDecoder.decodeObject(forKey: "instructions") as! [CodingInstruction]
        instructions = codingInstructions.map{VMInstruction($0)}
        }
    
    public func index(after:Int) -> Int
        {
        return(instructions.index(after:after))
        }
    
    public subscript(_ index:Int) -> VMInstruction
        {
        return(instructions[index])
        }
    
    public func dump()
        {
        var index = 0
        while index < instructions.count
            {
            let word = instructions[index]
            index += 1
            word.dump()
            }
        }
    }

