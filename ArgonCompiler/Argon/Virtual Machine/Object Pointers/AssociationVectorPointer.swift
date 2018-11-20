//
//  AssociationVectorPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/03.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public struct Association
    {
    public let key:UnsafeMutableRawPointer
    public let value:UnsafeMutableRawPointer
    
    init(key:UnsafeMutableRawPointer,value:UnsafeMutableRawPointer)
        {
        self.key = key
        self.value = value
        }
    }

public class AssociationVectorPointer:InstancePointerWrapper
    {
    public static let kIndexTraits:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kIndexCount:Int32 = 3
    public static let kIndexCapacity:Int32 = 4
    public static let kFixedSlotCount = 5
    
    public var isFull:Bool
        {
        return(self.count == self.capacity)
        }
    
    public var count:Int
        {
        get
            {
            return(Int(self[Int(AssociationVectorPointer.kIndexCount)]))
            }
        set
            {
            self[Int(AssociationVectorPointer.kIndexCount)] = UInt64(newValue)
            }
        }
    
    public var capacity:Int
        {
        get
            {
            return(Int(self[Int(AssociationVectorPointer.kIndexCapacity)]))
            }
        }
    
    public func association(at index:Int) -> Association
        {
        let offset = AssociationVectorPointer.kFixedSlotCount + index*2
        let cleanPointer = untaggedPointer(self.pointer)
        let association = Association(key: pointerAtIndexAtPointer(Int32(offset),cleanPointer),value: pointerAtIndexAtPointer(Int32(offset+1),cleanPointer))
        return(association)
        }
    
    public func append(key:Pointer,value:Pointer)
        {
        let offset = self.count * 2 + AssociationVectorPointer.kFixedSlotCount
        setPointerAtIndexAtPointer(key,Int32(offset),self.pointer)
        setPointerAtIndexAtPointer(value,Int32(offset+1),self.pointer)
        setWordAtIndexAtPointer(Word(self.count + 1),Int32(AssociationVectorPointer.kIndexCount),self.pointer)
        }
    
    public func append(key:Word,value:Pointer)
        {
        let offset = self.count * 2 + AssociationVectorPointer.kFixedSlotCount
        setWordAtIndexAtPointer(key,Int32(offset),self.pointer)
        setPointerAtIndexAtPointer(value,Int32(offset+1),self.pointer)
        setWordAtIndexAtPointer(Word(self.count + 1),Int32(AssociationVectorPointer.kIndexCount),self.pointer)
        }
    
    public func append(key:Pointer,value:Word)
        {
        let offset = self.count * 2 + AssociationVectorPointer.kFixedSlotCount
        setPointerAtIndexAtPointer(key,Int32(offset),self.pointer)
        setWordAtIndexAtPointer(value,Int32(offset+1),self.pointer)
        setWordAtIndexAtPointer(Word(self.count + 1),Int32(AssociationVectorPointer.kIndexCount),self.pointer)
        }
    
    public func append(key:Word,value:Word)
        {
        let offset = self.count * 2 + AssociationVectorPointer.kFixedSlotCount
        setWordAtIndexAtPointer(key,Int32(offset),self.pointer)
        setWordAtIndexAtPointer(value,Int32(offset+1),self.pointer)
        setWordAtIndexAtPointer(Word(self.count + 1),Int32(AssociationVectorPointer.kIndexCount),self.pointer)
        }
    
    public func append(key:String,value:Pointer,objectMemory:Memory) throws
        {
        let offset = self.count * 2 + AssociationVectorPointer.kFixedSlotCount
        let newString = try objectMemory.allocate(string: key)
        setPointerAtIndexAtPointer(newString,Int32(offset),self.pointer)
        setPointerAtIndexAtPointer(value,Int32(offset+1),self.pointer)
        setWordAtIndexAtPointer(Word(self.count + 1),Int32(AssociationVectorPointer.kIndexCount),self.pointer)
        }
    
    public func deleteAssociation(forKey key:Pointer)
        {
        for offset in stride(from:AssociationVectorPointer.kFixedSlotCount,to:AssociationVectorPointer.kFixedSlotCount + count * 2,by:2)
            {
            let local = pointerAtIndexAtPointer(Int32(offset),self.pointer)
            if local == key
                {
                for index in stride(from: offset + 2,to:(count-1)*2,by:2)
                    {
                    setPointerAtIndexAtPointer(pointerAtIndexAtPointer(Int32(index),self.pointer),Int32(index - 2),self.pointer)
                    }
                setWordAtIndexAtPointer(Word(self.count - 1),Int32(AssociationVectorPointer.kIndexCount),self.pointer)
                return
                }
            }
        }
    
    public func value(forKey key:Pointer) -> Pointer?
        {
        for offset in stride(from:AssociationVectorPointer.kFixedSlotCount,to:AssociationVectorPointer.kFixedSlotCount + count * 2,by:2)
            {
            let local = pointerAtIndexAtPointer(Int32(offset),self.pointer)
            if local == key
                {
                return(pointerAtIndexAtPointer(Int32(offset+1),self.pointer))
                }
            }
        return(nil)
        }

    public func value(forKey key:String) -> Pointer?
        {
        for offset in stride(from:AssociationVectorPointer.kFixedSlotCount,to:AssociationVectorPointer.kFixedSlotCount + count * 2,by:2)
            {
            let local = StringPointerWrapper(pointerAtIndexAtPointer(Int32(offset),self.pointer))
            if local.string == key
                {
                return(pointerAtIndexAtPointer(Int32(offset+1),self.pointer))
                }
            }
        return(nil)
        }
    }
