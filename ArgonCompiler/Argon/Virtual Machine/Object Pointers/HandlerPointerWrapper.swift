//
//  HandlerPointerWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class HandlerPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kHandlerInstructionPointerIndex:Int32 = 3
    public static let kHandlerIPIndex:Int32 = 4
    public static let kTypeSymbolIndex:Int32 = 5
    public static let kSignalingInstructionPointerIndex:Int32 = 6
    public static let kSignalingIPIndex:Int32 = 7
    public static let kPreviousActiveHandlerIndex:Int32 = 8
    public static let kStackChunkCountIndex:Int32 = 9
    public static let kStackChunkAllocationBlockPointerIndex:Int32 = 10
    
    public static let kFixedSlotCount:Int = 11
    
    public var handlerInstructionPointer:Pointer
        {
        get
            {
            return(pointerAtIndexAtPointer(HandlerPointerWrapper.kHandlerInstructionPointerIndex,self.pointer))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue,HandlerPointerWrapper.kHandlerInstructionPointerIndex,self.pointer)
            }
        }
    
    public var handlerIP:Int32
        {
        get
            {
            return(Int32(wordAtIndexAtPointer(HandlerPointerWrapper.kHandlerIPIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),HandlerPointerWrapper.kHandlerIPIndex,self.pointer)
            }
        }
    
    public var signalingInstructionPointer:Pointer
        {
        get
            {
            return(pointerAtIndexAtPointer(HandlerPointerWrapper.kSignalingInstructionPointerIndex,self.pointer))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue,HandlerPointerWrapper.kSignalingInstructionPointerIndex,self.pointer)
            }
        }
    
    public var stackChunkCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(HandlerPointerWrapper.kStackChunkCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),HandlerPointerWrapper.kStackChunkCountIndex,self.pointer)
            }
        }
    
    public var allocationBlockPointer:Pointer
        {
        get
            {
            return(pointerAtIndexAtPointer(HandlerPointerWrapper.kStackChunkAllocationBlockPointerIndex,self.pointer))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue,HandlerPointerWrapper.kStackChunkAllocationBlockPointerIndex,self.pointer)
            }
        }
    
    public func stackWords() -> [Word]
        {
        var words:[Word] = []
        let wrapper = AllocationBlockPointerWrapper(self.allocationBlockPointer)
        let count = wrapper.capacity
        for index in 0..<count
            {
            words.append(wrapper.word(at: index))
            }
        return(words)
        }
    
    public func setStackWords(_ words:[Word]) throws
        {
        let memory = Memory.memory(of: self.pointer)
        let aPointer = try memory!.allocate(allocationBlockWithSlotCount: words.count)
        let wrapper = AllocationBlockPointerWrapper(aPointer)
        self.allocationBlockPointer = aPointer
        for index in 0..<words.count
            {
            wrapper.setWord(words[index],at:index)
            }
        }
    
    public var signalingIP:Int32
        {
        get
            {
            return(Int32(wordAtIndexAtPointer(HandlerPointerWrapper.kSignalingIPIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),HandlerPointerWrapper.kSignalingIPIndex,self.pointer)
            }
        }
    
    public var symbol:String
        {
        get
            {
            return(StringPointerWrapper(pointerAtIndexAtPointer(HandlerPointerWrapper.kTypeSymbolIndex,self.pointer)).string)
            }
        }
    
    public func setSymbol(_ string:String,memory:Memory) throws
        {
        setPointerAtIndexAtPointer(try memory.allocate(symbol: string),HandlerPointerWrapper.kTypeSymbolIndex,self.pointer)
        }
    }
