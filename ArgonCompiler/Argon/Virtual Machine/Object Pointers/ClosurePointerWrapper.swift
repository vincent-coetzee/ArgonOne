//
//  ClosurePointer.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

import SharedMemory

public class ClosurePointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kVariableCountIndex:Int32 = 3
    public static let kCodeBlockIndex:Int32 = 4
    
    public static let kFixedSlotCount = 5
    
    public var codeBlock:CodeBlockPointerWrapper
        {
        return(CodeBlockPointerWrapper(pointerAtIndexAtPointer(ClosurePointerWrapper.kCodeBlockIndex,self.pointer)))
        }
    
    public var codeBlockPointer:Pointer
        {
        get
            {
            return(pointerAtIndexAtPointer(ClosurePointerWrapper.kCodeBlockIndex,self.pointer))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue,ClosurePointerWrapper.kCodeBlockIndex,self.pointer)
            }
        }
    }
