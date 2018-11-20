//
//  ArgonInstanceElement.swift
//  ArgonInspector
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class ArgonInstanceElement
    {
    public static let kTagMask:UInt64 = UInt64(7) << UInt64(60)
    public static let kTagClearMask = ~(UInt64(7) << UInt64(60))
    public static let kTagInteger:UInt64 = UInt64(0) << UInt64(60)
    public static let kTagFloat:UInt64 = UInt64(1) << UInt64(60)
    public static let kTagByte:UInt64 = UInt64(2) << UInt64(60)
    public static let kTagBoolean:UInt64 = UInt64(3) << UInt64(60)
    public static let kTagInstance:UInt64 = UInt64(4) << UInt64(60)
    public static let kTagForwarded:UInt64 = UInt64(1) << UInt64(59)
    
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
    
    public class func bitString(of value:UInt) -> String
        {
        var bitPattern = UInt(1)
        var string = ""
        for index in 1...64
            {
            string += (value & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        let output = String(String(string.reversed()).dropFirst())
        return(output)
        }
        
    internal var address:Int?
    internal var word:UInt64
    internal var pointer:UnsafeMutablePointer<UInt64>?
    
    public var bitString:String
        {
        return(ArgonInstanceElement.bitString(of: UInt(word)))
        }
    
    public var cellIdentifier:String
        {
        return("ERROR")
        }
    
    public init(address:Int)
        {
        self.address = address
        pointer = UnsafeMutablePointer<UInt64>(bitPattern: address)
        word = pointer![0]
        }
    
    public init(word:UInt64)
        {
        self.word = word
        self.address = 0
        self.pointer = nil
        }
    
    public func initCell(view:NSView?)
        {
        }
    
    public func cellHeight() -> CGFloat
        {
        return(0)
        }
    }
