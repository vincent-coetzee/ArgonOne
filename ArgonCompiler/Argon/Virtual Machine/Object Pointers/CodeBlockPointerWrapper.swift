//
//  CodeBlockPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class CodeBlockPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kInstructionCountIndex:Int32 = 3
    public static let kFlagsIndex:Int32 = 4
    public static let kInstructionsIndex:Int32 = 5
    
    public static let kFixedSlotCount = 6
    
    public static let kRunnableFlagsMask = ArgonWord(1)
    
    public var runnable:Bool
        {
        get
            {
            let word = self.flags
            return((word & CodeBlockPointerWrapper.kRunnableFlagsMask) == CodeBlockPointerWrapper.kRunnableFlagsMask)
            }
        set
            {
            var word = self.flags
            if newValue
                {
                word |= CodeBlockPointerWrapper.kRunnableFlagsMask
                }
            else
                {
                word &= ~CodeBlockPointerWrapper.kRunnableFlagsMask
                }
             self.flags = word
            }
        }
    
    public var flags:ArgonWord
        {
        get
            {
            return(wordAtIndexAtPointer(CodeBlockPointerWrapper.kFlagsIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,CodeBlockPointerWrapper.kFlagsIndex,self.pointer)
            }
        }
    
    public var instructionCount:Int
        {
        return(Int(wordAtIndexAtPointer(Int32(CodeBlockPointerWrapper.kInstructionCountIndex),self.pointer)))
        }
    
    public var instructionPointer:Pointer
        {
        return(incrementPointerBy(self.pointer,CodeBlockPointerWrapper.kInstructionsIndex * Int32(MemoryLayout<UInt64>.size)))
        }
    
    public var instructionList:[VMInstruction]
        {
        var list:[VMInstruction] = []
        let instructionPointer = self.instructionPointer
        var index = Int32(0)
        while index < Int32(self.instructionCount)
            {
            let word = wordAtIndexAtPointer(index,instructionPointer)
            let instruction = VMInstruction(word)
            instruction.IP = list.count
            list.append(instruction)
            index += 1
            if instruction.mode == .address
                {
                instruction.addressWord = wordAtIndexAtPointer(index,instructionPointer)
                index += 1
                }
            }
        return(list)
        }
    }
