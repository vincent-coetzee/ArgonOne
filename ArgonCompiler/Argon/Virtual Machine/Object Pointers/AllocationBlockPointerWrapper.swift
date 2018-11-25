//
//  AllocationBlockPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/10.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class AllocationBlockPointerWrapper:InstancePointerWrapper
    {
    static let kHeaderIndex:Int32 = 0
    static let kTraitsIndex:Int32 = 1
    static let kMonitorIndex:Int32 = 2
    static let kCapacityIndex:Int32 = 3
    
    static let kFixedSlotCount:Int32 = 4
    
    public func copyContents(of oldPointer: Pointer)
        {
        let wordSize = Int32(MemoryLayout<UInt64>.size)
        let oldCapacity = wordAtIndexAtPointer(AllocationBlockPointerWrapper.kCapacityIndex,oldPointer)
        copyBytes(self.pointer,AllocationBlockPointerWrapper.kFixedSlotCount*wordSize,oldPointer,AllocationBlockPointerWrapper.kFixedSlotCount*wordSize,Int32(oldCapacity)*wordSize)
        }
    
    public var capacity:Int
        {
        return(Int(wordAtIndexAtPointer(AllocationBlockPointerWrapper.kCapacityIndex,self.pointer)))
        }
    
    public func word(at index:Int) -> Word
        {
        let actualIndex = AllocationBlockPointerWrapper.kFixedSlotCount + Int32(index)
        return(wordAtIndexAtPointer(actualIndex,self.pointer))
        }
    
    public func setWord(_ word:Word,at index:Int)
        {
        let actualIndex = AllocationBlockPointerWrapper.kFixedSlotCount + Int32(index)
        setWordAtIndexAtPointer(word,actualIndex,self.pointer)
        }
    }
