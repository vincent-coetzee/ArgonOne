//
//  ArgonBitSet.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonBitSet
    {
    public static let kBitsPerWord = 8 * 8
    
    public private(set) var count:Int
    public private(set) var setCount:Int = 0
    public private(set) var unsetCount:Int = 0
    
    public private(set) var words:[UInt64] = []
    
    public var bitString:String
        {
        return(words.map{Argon.bitString(of: $0)}.joined(separator: " "))
        }
    
    init(count:Int)
        {
        self.count = count
        initInnards()
        }
    
    public func setWord(_ word:UInt64,at:Int)
        {
        words[at] = word
        }
    
    private func initInnards()
        {
        let neededWords = ((count / ArgonBitSet.kBitsPerWord) +  1)*ArgonBitSet.kBitsPerWord
        for _ in 0..<neededWords
            {
            words.append(0)
            }
        setCount = count
        unsetCount = 0
        }
    
    public func setBit(at index:Int)
        {
        let wordIndex = index / ArgonBitSet.kBitsPerWord
        let bitOffset = index % ArgonBitSet.kBitsPerWord
        words[wordIndex] |= UInt64(1) << UInt64(bitOffset)
        setCount += 1
        unsetCount = count - setCount
        }
    
    public func setBit(pattern:UInt,at index:Int)
        {
        let wordIndex = index / ArgonBitSet.kBitsPerWord
        let bitOffset = index % ArgonBitSet.kBitsPerWord
        words[wordIndex] |= UInt64(pattern) << UInt64(bitOffset)
        setCount += Int(numberOfSetBits(in: pattern))
        unsetCount = count - setCount
        }
    
    public func firstUnsetIndex() -> Int?
        {
        for wordIndex in 1...words.count
            {
            let word = words[wordIndex - 1]
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
    
    public func bitString(of value:UInt) -> String
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
    
    public func valueOfBitString(_ string:String) -> UInt64
        {
        var index = string.endIndex
        var mask:UInt64 = 1
        var value:UInt64 = 0
        while index != string.startIndex
            {
            if string[index] == "1"
                {
                value |= mask
                }
            mask <<= 1
            index = string.index(before: index)
            }
        return(value)
        }
    
    public func bit(at index:Int) -> UInt
        {
        let wordIndex = index / ArgonBitSet.kBitsPerWord
        let bitOffset = index % ArgonBitSet.kBitsPerWord
        var bit = words[wordIndex] & (UInt64(1) << UInt64(bitOffset))
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
        var word = words[wordIndex]
        word &= UInt64(offset) << UInt64(lowerBound)
        word >>= UInt64(lowerBound)
        return(UInt(word))
        }
    }
