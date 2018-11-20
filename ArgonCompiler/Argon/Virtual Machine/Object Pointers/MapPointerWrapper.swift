//
//  MapPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class MapPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex = 0
    public static let kTraitsIndex = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kCountIndex = 3
    public static let kCapacityIndex = 4
    public static let kKeyTraitsIndex = 5
    public static let kValueTraitsIndex = 6
    public static let kHashBucketCountIndex = 7
    public static let kHashBucketsIndex = 8
    public static let kHashBucketBucketPrimary = 757
    public static let kHashBucketVectorSize = 149
    
    public static let kFixedSlotCount = 9
    
    public var traits:[TraitsPointerWrapper]
        {
        return([])
        }
    
    public var count:Int
        {
        get
            {
            return(Int(self[MapPointerWrapper.kCountIndex]))
            }
        set
            {
            self[MapPointerWrapper.kCountIndex] = UInt64(newValue)
            }
        }
    
    public var capacity:Int
        {
        return(Int(self[MapPointerWrapper.kCapacityIndex]))
        }
    
    public func dump()
        {
        for index in Int32(MapPointerWrapper.kFixedSlotCount)..<Int32(MapPointerWrapper.kFixedSlotCount+Argon.kHashMapPrime)
            {
            let aPointer = pointerAtIndexAtPointer(index,self.pointer)
            if !isPointerNil(aPointer)
                {
                let vector = AssociationVectorPointer(aPointer)
                for vectorIndex in 0..<vector.count
                    {
                    let association = vector.association(at: vectorIndex)
                    let string = StringPointerWrapper(association.key).string
                    print("(\(string),\(association.value))")
                    }
                }
            }
        }
    
    public func setPointer(_ value:Pointer,forKey key:Pointer) throws
        {
        var hashValue = abs(key.hashValue)
        hashValue = hashValue % Argon.kHashMapPrime
        let vector = AssociationVectorPointer(pointerAtIndexAtPointer(Int32(MapPointerWrapper.kFixedSlotCount+hashValue),self.pointer))
        if vector.isFull
            {
            throw(VirtualMachineSignal.sizeOverflow)
            }
        vector.append(key:key,value:value)
        self.count += 1
        }
    
    public func setPointer(_ value:Pointer,forKey key:String) throws
        {
        var hashValue = abs(key.hashValue)
        hashValue = hashValue % Argon.kHashMapPrime
        let pointer = pointerAtIndexAtPointer(Int32(MapPointerWrapper.kFixedSlotCount+hashValue),self.pointer)
        let vector = isPointerNil(pointer) ? try newAssociationVector(at: hashValue) : AssociationVectorPointer(pointer)
        if vector.isFull
            {
            throw(VirtualMachineSignal.sizeOverflow)
            }
        try vector.append(key:key,value:value,objectMemory:objectMemory!)
        self.count += 1
        }
    
    private func newAssociationVector(at bucket:Int) throws -> AssociationVectorPointer
        {
        guard let memory = self.objectMemory else
            {
            throw(VirtualMachineSignal.objectMemoryMissing)
            }
        let newVector = try memory.allocate(associationVectorWithCapacity: 127)
        setPointerAtIndexAtPointer(newVector,Int32(MapPointerWrapper.kFixedSlotCount+bucket),self.pointer)
        return(AssociationVectorPointer(newVector))
        }
    
    public func setValue(_ value:Word,forKey key:Pointer) throws
        {
        var hashValue = abs(key.hashValue)
        hashValue = hashValue % Argon.kHashMapPrime
        let pointer = pointerAtIndexAtPointer(Int32(MapPointerWrapper.kFixedSlotCount+hashValue),self.pointer)
        let vector = isPointerNil(pointer) ? try newAssociationVector(at: hashValue) : AssociationVectorPointer(pointer)
        if vector.isFull
            {
            throw(VirtualMachineSignal.sizeOverflow)
            }
        vector.append(key:key,value:value)
        self.count += 1
        }
    
    public func deleteValue(forKey key:Pointer)
        {
        var hashValue = abs(key.hashValue)
        hashValue = hashValue % Argon.kHashMapPrime
        let vectorPointer = pointerAtIndexAtPointer(Int32(MapPointerWrapper.kFixedSlotCount+hashValue),self.pointer)
        if !isPointerNil(vectorPointer)
            {
            let vector = AssociationVectorPointer(vectorPointer)
            vector.deleteAssociation(forKey: key)
            }
        }
    
    public func pointer(forKey key:Pointer) throws -> Pointer?
        {
        var hashValue = abs(key.hashValue)
        hashValue = hashValue % Argon.kHashMapPrime
        let vectorPointer = pointerAtIndexAtPointer(Int32(MapPointerWrapper.kFixedSlotCount+hashValue),self.pointer)
        if isPointerNil(vectorPointer)
            {
            return(nil)
            }
        else
            {
            let vector = AssociationVectorPointer(vectorPointer)
            return(vector.value(forKey: key))
            }
        }
    
    public func pointer(forKey key:String) throws -> Pointer?
        {
        var hashValue = abs(key.hashValue)
        hashValue = hashValue % Argon.kHashMapPrime
        let vectorPointer = pointerAtIndexAtPointer(Int32(MapPointerWrapper.kFixedSlotCount+hashValue),self.pointer)
        if isPointerNil(vectorPointer)
            {
            return(nil)
            }
        else
            {
            let vector = AssociationVectorPointer(vectorPointer)
            return(vector.value(forKey: key))
            }
        }
    
    private var objectMemory:Memory?
    
    init(_ pointer:UnsafeMutableRawPointer,objectMemory:Memory)
        {
        self.objectMemory = objectMemory;
        super.init(pointer)
        }
    }
