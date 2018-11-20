//
//  VectorPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class VectorPointer:InstancePointerWrapper
    {
    public static let kHeaderIndex = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kCountIndex:Int32 = 3
    public static let kCapacityIndex:Int32 = 4
    public static let kBlockPointerIndex:Int32 = 5
    public static let kSpareIndex:Int32 = 6
    
    public static let kFixedSlotCount = 67
    
    private var _cachedBlockPointer:Pointer?
    
    public var isFull:Bool
        {
        return(self.count >= self.capacity)
        }
    
    public var count:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(VectorPointer.kCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),VectorPointer.kCountIndex,self.pointer)
            }
        }
    
    public var blockPointer:Pointer
        {
        guard _cachedBlockPointer == nil else
            {
            return(_cachedBlockPointer!)
            }
        _cachedBlockPointer = pointerAtIndexAtPointer(VectorPointer.kBlockPointerIndex,self.pointer)
        return(_cachedBlockPointer!)
        }
    
    public var capacity:Int
        {
        return(Int(wordAtIndexAtPointer(VectorPointer.kCapacityIndex,self.pointer)))
        }
    
    public func item(at index:Int) -> Int64
        {
        return(Int64(wordAtIndexAtPointer(Int32(2+index),self.blockPointer)))
        }
    
    public func setItem(_ item:Int64,at index:Int)
        {
        setWordAtIndexAtPointer(Word(item),Int32(2+index),self.blockPointer)
        }
    
    public func append(_ element:Int64) throws
        {
        if self.isFull
            {
            try self.grow()
            }
        if isFull
            {
            throw(VirtualMachineFault.outOfMemory)
            }
        let index = AllocationBlockPointerWrapper.kFixedSlotCount + Int32(self.count)
        setWordAtIndexAtPointer(Word(element),index,self.blockPointer)
        self.count += 1
        }
    
    public func grow() throws
        {
        guard let memory = Memory.memory(of: self.pointer) else
            {
            print("Failing to grow Vector because owner memory can not be found")
            throw(VirtualMachineFault.failedToGrow)
            }
        let newCapacity = self.capacity * 7 / 4
        let newBlock = try memory.allocate(allocationBlockWithSlotCount: newCapacity)
        let oldBlockPointer = self.blockPointer
        let allocationBlockPointer = AllocationBlockPointerWrapper(newBlock)
        allocationBlockPointer.copyContents(of: oldBlockPointer)
        setWordAtIndexAtPointer(Word(newCapacity),VectorPointer.kCapacityIndex,self.pointer)
        setPointerAtIndexAtPointer(newBlock,VectorPointer.kBlockPointerIndex,self.pointer)
        }
    
    public func append(_ element:Pointer) throws
        {
        if self.isFull
            {
            try self.grow()
            }
        if isFull
            {
            throw(VirtualMachineFault.outOfMemory)
            }
        let index = AllocationBlockPointerWrapper.kFixedSlotCount + Int32(self.count)
        setPointerAtIndexAtPointer(element,index,self.blockPointer)
        self.count += 1
        }
    
    public func pointerItem(at index:Int) -> Pointer
        {
        let offset = AllocationBlockPointerWrapper.kFixedSlotCount + Int32(index)
        return(pointerAtIndexAtPointer(offset,self.blockPointer))
        }
    
    public func insert(_ element:Int64,at elementIndex:Int) throws
        {
        if self.isFull
            {
            try self.grow()
            }
        if isFull
            {
            throw(VirtualMachineFault.outOfMemory)
            }
        if self.count + 1 < self.capacity
            {
            for index in stride(from:self.count,to: elementIndex,by: -1)
                {
                setWordAtIndexAtPointer(wordAtIndexAtPointer(AllocationBlockPointerWrapper.kFixedSlotCount + Int32(index - 1),self.blockPointer),AllocationBlockPointerWrapper.kFixedSlotCount + Int32(index),self.blockPointer)
                }
            setWordAtIndexAtPointer(Word(element),AllocationBlockPointerWrapper.kFixedSlotCount + Int32(elementIndex),self.blockPointer)
            self.count += 1
            }
        else
            {
            throw(VirtualMachineFault.invalidIndex)
            }
        }
    
    public func remove(at elementIndex:Int) throws
        {
        let theCount = self.count
        if elementIndex >= theCount || theCount < 1
            {
            throw(VirtualMachineFault.invalidIndex)
            }
        for index in (Int32(elementIndex) + AllocationBlockPointerWrapper.kFixedSlotCount)..<(Int32(theCount) + AllocationBlockPointerWrapper.kFixedSlotCount - 1)
            {
            setWordAtIndexAtPointer(wordAtIndexAtPointer(index + 1,self.blockPointer),index,self.blockPointer)
            }
        self.count -= 1
        }
    }

