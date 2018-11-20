//
//  StringPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class StringPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex = 0
    public static let kTraitsIndex = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kCountIndex = 3
    public static let kCapacityIndex = 4
    public static let kSpareIndex = 5
    public static let kCharactersIndex = 6
    
    public static let kUpperShift = UInt64(32)
    public static let kUpperMask = UInt64(4294967295) << UInt64(32)
    
    public var string:String
        {
        get
            {
            let theCount = self.count
            var string = ""
            var characterCount = 0
            let wordCount = theCount/2 + (theCount % 2)
            for index in StringPointerWrapper.kCharactersIndex..<StringPointerWrapper.kCharactersIndex + wordCount
                {
                let word = self[index]
                var character = Int((word & StringPointerWrapper.kUpperMask) >> StringPointerWrapper.kUpperShift)
                string.append(Character(UnicodeScalar(character)!))
                characterCount += 1
                if characterCount < theCount
                    {
                    character = Int(word & ~StringPointerWrapper.kUpperMask)
                    string.append(Character(UnicodeScalar(character)!))
                    characterCount += 1
                    }
                }
            return(string)
            }
        set
            {
            var index = StringPointerWrapper.kCharactersIndex
            let theCount = newValue.count
            var byteCount = 0
            var loop = newValue.unicodeScalars.startIndex
            while loop < newValue.unicodeScalars.endIndex
                {
                var word = UInt64(newValue.unicodeScalars[loop].value) << StringPointerWrapper.kUpperShift
                byteCount += 1
                loop = newValue.unicodeScalars.index(after: loop)
                if byteCount < theCount
                    {
                    word |= UInt64(newValue.unicodeScalars[loop].value)
                    byteCount += 1
                    loop = newValue.unicodeScalars.index(after: loop)
                    }
                self[index] = word
                index += 1
                }
            self[StringPointerWrapper.kCountIndex] = UInt64(newValue.count)
            }
        }
    
    public var count:Int
        {
        return(Int(wordAtIndexAtPointer(Int32(StringPointerWrapper.kCountIndex),self.pointer)))
        }
    
    public var capacity:Int
        {
        return(Int(wordAtIndexAtPointer(Int32(StringPointerWrapper.kCapacityIndex),self.pointer)))
        }
    }
