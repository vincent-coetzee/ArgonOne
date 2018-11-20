//
//  MethodPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class MethodPointerWrapper:InstancePointerWrapper
    {
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kNameIndex:Int32 = 3
    public static let kParameterCountIndex:Int32 = 4
    public static let kInstructionCountIndex:Int32 = 5
    public static let kCodeBlockIndex:Int32 = 6
    public static let kFixedSlotCount = 7
    
    public var name:String
        {
        get
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(Int32(MethodPointerWrapper.kNameIndex),self.pointer))
            return(stringPointer.string)
            }
        set
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(Int32(MethodPointerWrapper.kNameIndex),self.pointer))
            if newValue.count < stringPointer.capacity
                {
                stringPointer.string = newValue
                }
            }
        }
    
    public var instructionCount:Int
        {
        return(Int(self[Int(MethodPointerWrapper.kInstructionCountIndex)]))
        }
    
    public var parameterCount:Int
        {
        return(Int(self[Int(MethodPointerWrapper.kParameterCountIndex)]))
        }
    
    public var codeBlock:CodeBlockPointerWrapper
        {
        get
            {
            return(CodeBlockPointerWrapper(pointerAtIndexAtPointer(MethodPointerWrapper.kCodeBlockIndex,self.pointer)))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue.pointer,MethodPointerWrapper.kCodeBlockIndex,self.pointer)
            }
        }
    
    public var codeBlockPointer:Pointer
        {
        get
            {
            return(pointerAtIndexAtPointer(MethodPointerWrapper.kCodeBlockIndex,self.pointer))
            }
        set
            {
            setPointerAtIndexAtPointer(newValue,MethodPointerWrapper.kCodeBlockIndex,self.pointer)
            }
        }
    
    public var instructionPointer:Pointer
        {
        return(pointerAtIndexAtPointer(CodeBlockPointerWrapper.kInstructionsIndex,pointerAtIndexAtPointer(MethodPointerWrapper.kCodeBlockIndex,self.pointer)))
        }
    }
