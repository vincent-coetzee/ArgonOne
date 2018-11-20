//
//  TraitsPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public struct MemorySlotLayout
    {
    var name:String
    var offset:Int
    var traits:Pointer
    
    init(_ name:String,_ offset:Int,_ traits:Pointer)
        {
        self.name = name
        self.offset = offset
        self.traits = traits
        }
    }

public class TraitsPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kNameIndex:Int32 = 3
    public static let kParentCountIndex:Int32 = 4
    public static let kSlotCountIndex:Int32 = 5
    public static let kFixedSlotCount = 6
    
    public var name:String
        {
        get
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(Int32(TraitsPointerWrapper.kNameIndex),self.pointer))
            return(stringPointer.string)
            }
        set
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(Int32(TraitsPointerWrapper.kNameIndex),self.pointer))
            if newValue.count < stringPointer.capacity
                {
                stringPointer.string = newValue
                }
            }
        }
    
    public var parentCount:Int
        {
        return(Int(self[Int(TraitsPointerWrapper.kParentCountIndex)]))
        }
    
    public var parents:[TraitsPointerWrapper]
        {
        var parents:[TraitsPointerWrapper] = []
        for index in 0..<self.parentCount
            {
            parents.append(TraitsPointerWrapper(pointerAtIndexAtPointer(Int32(index + TraitsPointerWrapper.kFixedSlotCount),self.pointer)))
            }
        return(parents)
        }
    
    public override var slotCount:Int
        {
        return(Int(wordAtIndexAtPointer(TraitsPointerWrapper.kSlotCountIndex,self.pointer)))
        }
    
    public func inherits(from:TraitsPointerWrapper) -> Bool
        {
        if from.name == self.name
            {
            return(true)
            }
        let parents = self.parents
        for parent in parents
            {
            if parent.inherits(from: from)
                {
                return(true)
                }
            }
        return(false)
        }
    }
