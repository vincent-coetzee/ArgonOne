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
    public static let kCodeBlockIndex:Int32 = 3
    public static let kTypeSymbolIndex:Int32 = 4
    
    public static let kFixedSlotCount:Int = 5
    
    public var instructionPointer:Pointer
        {
        get
            {
            return(CodeBlockPointerWrapper(self.codeBlockPointer).instructionPointer)
            }
        }
    
    public var codeBlockPointer:Pointer
        {
        get
            {
            return(pointerAtIndexAtPointer(HandlerPointerWrapper.kCodeBlockIndex,self.pointer))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue,HandlerPointerWrapper.kCodeBlockIndex,self.pointer)
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
    
    public var instructionCount:Int
        {
        get
            {
            return(CodeBlockPointerWrapper(self.codeBlockPointer).instructionCount)
            }
        }
    }
