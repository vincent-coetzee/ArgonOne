//
//  BitSetPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class BitSetPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex = 0
    public static let kTraitsIndex = 1
    public static let kTraitsCountIndex = 2
    public static let kCountIndex = 3
    public static let kSetIndex = 4
    public static let kUnsetIndex = 5
    public static let kWordCountIndex = 6
    public static let kWordsIndex = 67
    
    public var traits:[TraitsPointerWrapper]
        {
        return([])
        }
    
    public var traitsCount:Int
        {
        return(Int(self[BitSetPointerWrapper.kTraitsCountIndex]))
        }
    
    public var count:Int
        {
        return(Int(self[BitSetPointerWrapper.kCountIndex]))
        }
    
    public var setCount:Int
        {
        get
            {
            return(Int(self[BitSetPointerWrapper.kSetIndex]))
            }
        set
            {
            self[BitSetPointerWrapper.kSetIndex] = UInt64(newValue)
            }
        }

    public var unsetCount:Int
        {
        get
            {
            return(Int(self[BitSetPointerWrapper.kUnsetIndex]))
            }
        set
            {
            self[BitSetPointerWrapper.kUnsetIndex] = UInt64(newValue)
            }
        }
    
    public var wordCount:Int
        {
        get
            {
            return(Int(self[BitSetPointerWrapper.kWordCountIndex]))
            }
        set
            {
            self[BitSetPointerWrapper.kWordCountIndex] = UInt64(newValue)
            }
        }
    
    public func firstUnsetIndex() -> Int?
        {
        for wordIndex in 1...self.wordCount
            {
            let word = self[wordIndex + 8 - 1]
            var mask:UInt64 = 1
            for bit in 1...ArgonBitSet.kBitsPerWord
                {
                if !((word & mask) == mask)
                    {
                    return(wordIndex * ArgonBitSet.kBitsPerWord + bit)
                    }
                mask <<= 1
                }
            }
        return(nil)
        }
    
    public func bit(at index:Int) -> UInt
        {
        let wordIndex = index / ArgonBitSet.kBitsPerWord
        let bitOffset = index % ArgonBitSet.kBitsPerWord
        var bit = self[wordIndex + 8] & (UInt64(1) << UInt64(bitOffset))
        bit >>= UInt64(bitOffset)
        return(UInt(bit))
        }
    
    public func bitPattern(at range:ClosedRange<Int>) -> UInt
        {
        let lowerBound = range.lowerBound
        let upperBound = range.upperBound
        let width = upperBound - lowerBound
        let wordIndex = lowerBound / ArgonBitSet.kBitsPerWord
        var offset = 1
        for _ in 0...width
            {
            offset *= 2
            }
        offset -= 1
        var word = self[wordIndex + 8]
        word &= UInt64(offset) << UInt64(lowerBound)
        word >>= UInt64(lowerBound)
        return(UInt(word))
        }
    public func setBit(at index:Int)
        {
        let wordIndex = index / ArgonBitSet.kBitsPerWord
        let bitOffset = index % ArgonBitSet.kBitsPerWord
        self[wordIndex + 8] |= UInt64(1) << UInt64(bitOffset)
        setCount += 1
        unsetCount = count - setCount
        }
    
    public func numberOfSetBits(in bits:UInt) -> UInt
        {
        var aCount:UInt = 0
        var mask:UInt = 1
        for _ in 1...ArgonBitSet.kBitsPerWord
            {
            aCount += (bits & mask) == mask ? 1 : 0
            mask <<= 1
            }
        return(aCount)
        }
    
    public func setBit(pattern:UInt,at index:Int)
        {
        let wordIndex = index / ArgonBitSet.kBitsPerWord
        let bitOffset = index % ArgonBitSet.kBitsPerWord
        self[wordIndex + 8] |= UInt64(pattern) << UInt64(bitOffset)
        setCount += Int(self.numberOfSetBits(in: pattern))
        unsetCount = count - setCount
        }
    }
