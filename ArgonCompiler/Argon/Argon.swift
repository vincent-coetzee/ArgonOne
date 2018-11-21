//
//  Argon.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public typealias ArgonWord = UInt64

public let ArgonWordSize = MemoryLayout<ArgonWord>.size

extension ArgonWord
    {
    init(high:Int32,low:Int32)
        {
        self.init(ArgonWord(high) << ArgonWord(32) | ArgonWord(low))
        }
    }
    
public struct Argon
    {
    public static let kName = "Argon"
    public static let kVersion = "0.0.1"
    public static let kAuthorName = "Vincent Coetzee"
    
    public static let kHashMapPrime = 131
    public static let kHashBucketDefaultMaximumCapacity = 131

    public static let kKeyEntriesPerPage = 131
    public static let kPageSizeInBytes = 4096 * 4096 * 256
    public static let kKeyAllocationSize = 131 * 256
    
    public static let kTypeInstance:Int = 0
    public static let kTypeString:Int = 1
    public static let kTypeVector:Int = 2
    public static let kTypeMap:Int = 3
    public static let kTypeMethod:Int = 4
    public static let kTypeSlot:Int = 5
    public static let kTypeHashBucket:Int = 6
    public static let kTypeTraits:Int = 7
    public static let kTypeBitSet:Int = 8
    public static let kTypeAssociationVector:Int = 9
    public static let kTypeGenericMethodInstance:Int = 10
    public static let kTypeGenericMethod:Int = 11
    public static let kTypeCodeBlock:Int = 12
    public static let kTypeAllocationBlock:Int = 13
    public static let kTypeHandler:Int = 14
    public static let kTypeSymbolTree:Int = 15
    
    public static let kDefaultMemorySegmentSize = 1024 * 1024 * 256 // 128 MB
    public static let kDefaultMemoryEdenSize = 1024 * 1024 * 64 // 16 MB
    public static let kDefaultDataSegmentSize = 1024 * 1024 * 64 // 16 MB
    public static let kDefaultThreadMemorySize = 1024 * 1024 * 5 // 5MB
    public static let kSharedMemorySize = 4 * 1024 * 1024
    
    public static let kTagMask:UInt64 = UInt64(15) << UInt64(59)
    public static let kTagClearMask:UInt64 = ~(UInt64(15) << UInt64(59))
    public static let kTagInteger:UInt64 = UInt64(0) << UInt64(59)
    public static let kTagFloat:UInt64 = UInt64(1) << UInt64(59)
    public static let kTagByte:UInt64 = UInt64(2) << UInt64(59)
    public static let kTagBoolean:UInt64 = UInt64(3) << UInt64(59)
    public static let kTagInstance:UInt64 = UInt64(4) << UInt64(59)
    public static let kTagDate:UInt64 = UInt64(5) << UInt64(59)
    public static let kTagVector:UInt64 = UInt64(6) << UInt64(59)
    public static let kTagMap:UInt64 = UInt64(7) << UInt64(59)
    public static let kTagCodeBlock:UInt64 = UInt64(8) << UInt64(59)
    public static let kTagBlock:UInt64 = UInt64(9) << UInt64(59)
    public static let kTagHandler:UInt64 = UInt64(10) << UInt64(59)
    public static let kTagMethod:UInt64 = UInt64(11) << UInt64(59)
    public static let kTagClosure:UInt64 = UInt64(12) << UInt64(59)
    public static let kTagTraits:UInt64 = UInt64(13) << UInt64(59)
    public static let kTagString:UInt64 = UInt64(14) << UInt64(59)
    public static let kTagSymbol:UInt64 = UInt64(15) << UInt64(59)
    public static let kTagForwarded:UInt64 = UInt64(1) << UInt64(58)
    public static let kCleanAddressMask:UInt64 = ~(UInt64(15) << UInt64(60) | UInt64(1) << UInt64(58))
    public static let kTagMaskShift:UInt64 = UInt64(59)
    public static let kTagHeaderFlagValue = UInt64(5)

    public static let kDataSegmentStartOffset = 8
    
    public static let kOffsetOfFirstRegisterForUse = 7
    public static let kNumberOfReservedRegisters = 1
    public static let kOffsetOfFirstFloatingPointRegisterForUse = 39
    public static let kNumberOfRegisters = 32
    
    private static var _counter = 1
    
    public static var nextCounter:Int
        {
        let number = _counter
        _counter += 1
        return(number)
        }
    
    private static var _nextOffset = 32
    
    public static func nextOffsetInDataSegment() -> Int
        {
        let offset = _nextOffset
        _nextOffset += 8
        return(offset)
        }
    
    public static func valueOf(bits:Word,at shift:Word,in word:Word) -> Int
        {
        let mask = bits << shift
        return(Int((word & mask) >> shift))
        }
    
    public static func setValueOf(bits:Word,at shift:Word,in word:inout Word,to newValue:Int)
        {
        let newWordValue = Word(newValue)
        let mask = bits << shift
        let newWord = word & ~mask
        let clampedValue = newWordValue & bits
        word = newWord | (clampedValue << shift)
        }
    
    public static func hexString(of: UInt,length:Int) -> String
        {
        let mask = UInt(length - 1)
        let maskedValue = of & mask
        let hexString = String(format: "%012X",maskedValue)
        return(hexString)
        }
    
    public static func bitString(of value:UInt,length:Int) -> String
        {
        var bitPattern = UInt(1)
        var string = ""
        for index in 1...length
            {
            string += (value & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        return(String(string.reversed()))
        }

    public static func bitString(of pointer:Pointer) -> String
        {
        return(self.bitString(of: pointerAsWord(pointer)))
        }
    
    public static func bitString(of word:Word) -> String
        {
        return(self.bitString(of: UInt(word)))
        }
    
    public static func bitString(of value:UInt) -> String
        {
        var bitPattern = UInt(1)
        var string = ""
        for index in 1...64
            {
            string += (value & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        return(String(string.reversed()))
        }
    
    public static func typeName(for value:Int) -> String
        {
        switch(value)
            {
            case kTypeInstance:
                return("INSTANCE")
            case kTypeString:
                return("STRING")
            case kTypeVector:
                return("VECTOR")
            case kTypeMap:
                return("MAP")
            case kTypeMethod:
                return("METHOD")
            case kTypeSlot:
                return("SLOT")
            case kTypeHashBucket:
                return("HASHBUCKET")
            case kTypeTraits:
                return("TRAITS")
            case kTypeBitSet:
                return("BITSET")
            default:
                return("UNKNOWN")
            }
        }
    }
