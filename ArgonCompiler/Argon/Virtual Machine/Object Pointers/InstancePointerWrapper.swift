//
//  InstancePointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class InstancePointerWrapper
    {
    public static let kSlotCountMask = UInt64(65535) << UInt64(32)
    public static let kExtraWordCountMask = UInt64(4095) << UInt64(48)
    public static let kGenerationMask = UInt64(255) << UInt64(24)
    public static let kForwardedMask = UInt64(1) << UInt64(23)
    public static let kTypeFlagMask = UInt64(255) << UInt64(8)
    public static let kFlagsMask = UInt64(255) << UInt64(0)
    
    public static let kSlotCountShift = UInt64(32)
    public static let kExtraWordCountShift = UInt64(48)
    public static let kGenerationShift = UInt64(24)
    public static let kForwardedShift = UInt64(23)
    public static let kTypeFlagShift = UInt64(8)
    public static let kFlagsShift = UInt64(0)
    
    public static let kTypeInstance:Int = 0
    public static let kTypeString:Int = 1
    public static let kTypeVector:Int = 2
    public static let kTypeMap:Int = 3
    public static let kTypeMethod:Int = 4
    public static let kTypeSlot:Int = 5
    public static let kTypeHashBucket:Int = 6
    public static let kTypeTraits:Int = 7
    public static let kTypeBitSet:Int = 8
    public static let kTypeSymbol:Int = 9
    
    private var cachedSlotCount:Int?
    
    public var slotCount:Int
        {
        guard let count = cachedSlotCount else
            {
            let header = self.instanceHeader
            let slots = (header & InstancePointerWrapper.kSlotCountMask) >> InstancePointerWrapper.kSlotCountShift
            let extra = (header & InstancePointerWrapper.kExtraWordCountMask) >> InstancePointerWrapper.kExtraWordCountShift
            cachedSlotCount = Int(slots + extra + 1)
            return(cachedSlotCount!)
            }
        return(count)
        }
    
    public var headerSlotCount:Int
        {
        let count = (self.instanceHeader & InstancePointerWrapper.kSlotCountMask) >> InstancePointerWrapper.kSlotCountShift
        return(Int(count))
        }
    
    public var headerExtraWordCount:Int
        {
        let count = (self.instanceHeader & InstancePointerWrapper.kExtraWordCountMask) >> InstancePointerWrapper.kExtraWordCountShift
        return(Int(count))
        }
    
    public var headerFlags:Int
        {
        let count = (self.instanceHeader & InstancePointerWrapper.kFlagsMask) >> InstancePointerWrapper.kFlagsShift
        return(Int(count))
        }
    
    public var headerTypeFlags:Int
        {
        let count = (self.instanceHeader & InstancePointerWrapper.kTypeFlagMask) >> InstancePointerWrapper.kTypeFlagShift
        return(Int(count))
        }
    
    public var headerGenerationCount:Int
        {
        let count = (self.instanceHeader & InstancePointerWrapper.kGenerationMask) >> InstancePointerWrapper.kGenerationShift
        return(Int(count))
        }
    
    public var headerForwarded:Int
        {
        let count = (self.instanceHeader & InstancePointerWrapper.kForwardedMask) >> InstancePointerWrapper.kForwardedShift
        return(Int(count))
        }
    
    public var instanceHeader:UInt64
        {
        return(self[0])
        }
    
    public func pointer(at index:Int32) -> UnsafeMutableRawPointer
        {
        return(untaggedPointer(pointerAtIndexAtPointer(index,self.pointer)))
        }
    
    internal var pointer:UnsafeMutableRawPointer
    
    init(_ pointer:UnsafeMutableRawPointer)
        {
        self.pointer = untaggedPointer(pointer)
        }
    
    public var traitsPointer:Pointer
        {
        return(pointerAtIndexAtPointer(1,self.pointer))
        }
    
    public subscript(_ index:Int) -> ArgonWord
        {
        get
            {
            return(UInt64(wordAtIndexAtPointer(Int32(index),pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Int32(index),pointer)
            }
        }
    }
