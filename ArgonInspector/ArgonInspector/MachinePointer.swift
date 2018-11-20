//
//  ObjectPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class MachinePointer
    {
    public static let kTagMask:UInt64 = UInt64(7) << UInt64(60)
    public static let kTagClearMask = ~(UInt64(7) << UInt64(60))
    public static let kTagInteger:UInt64 = UInt64(0) << UInt64(60)
    public static let kTagFloat:UInt64 = UInt64(1) << UInt64(60)
    public static let kTagByte:UInt64 = UInt64(2) << UInt64(60)
    public static let kTagBoolean:UInt64 = UInt64(3) << UInt64(60)
    public static let kTagInstance:UInt64 = UInt64(4) << UInt64(60)
    public static let kTagForwarded:UInt64 = UInt64(1) << UInt64(59)
    
    public static let emptyPointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
    
    @inline(__always)
    public static func shouldBeCopied(_ address:UInt64) -> Bool
        {
        let result = (address & kTagInteger) == kTagInteger || (address & kTagFloat) == kTagFloat || (address & kTagBoolean) == kTagBoolean || (address & kTagByte) == kTagByte
        return(!result)
        }
    
    @inline(__always)
    public static func isForwardedAddress(_ address:UInt64) -> Bool
        {
        return((address & kTagForwarded) == kTagForwarded)
        }
    
    @inline(__always)
    public static func untaggedValue(_ address:UInt64) -> UInt64
        {
        return(address & kTagClearMask & ~kTagForwarded)
        }
    
    @inline(__always)
    public static func unforwardedAddress(_ address:UInt64) -> UInt64
        {
        return(address & ~(kTagForwarded))
        }
    
    @inline(__always)
    public static func taggedInteger(_ integer:Int32) -> UInt64
        {
        let value = UInt64(integer) | kTagInteger
        return(value)
        }
    
    @inline(__always)
    public static func taggedInstance(_ address:UInt64) -> UInt64
        {
        let value = address | kTagInstance
        return(value)
        }
    
    @inline(__always)
    public static func isTaggedInstance(_ address:UInt64) -> Bool
        {
        return((address & kTagInstance) == kTagInstance)
        }
    
    @inline(__always)
    public static func forwardedAddress(_ address:UInt64) -> UInt64
        {
        return(address | kTagForwarded)
        }
    
    @inline(__always)
    public static func baseWithOffsetAddress(base:UnsafeMutableRawPointer,offset:Int) -> UInt64
        {
        return(UInt64(UInt(bitPattern: base)) + UInt64(offset))
        }
    
    @inline(__always)
    public static func baseWithOffsetAddress(base:Int,offset:Int) -> UInt64
        {
        return(UInt64(UInt(bitPattern: base)) + UInt64(offset))
        }
    
    @inline(__always)
    public static func baseWithOffsetAddress(base:UnsafeMutableRawPointer,offset:Int,tag:UInt64) -> UInt64
        {
        return((UInt64(UInt(bitPattern: base)) + UInt64(offset)) | tag)
        }
    
    public static func bitString(of value:UInt64) -> String
        {
        return(self.bitString(of: UInt(value)))
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
    
    public static func hexString(of: UInt,length:Int) -> String
        {
        let mask = UInt(length - 1)
        let maskedValue = of & mask
        let hexString = String(format: "%0X",maskedValue)
        return(hexString)
        }
    
    public internal(set) var address:UInt64 = 0
    public internal(set) var pointer:UnsafeMutablePointer<UInt64>
    
    required init(_ address:UInt64)
        {
        if address == 0
            {
            pointer = MachinePointer.emptyPointer
            }
        else
            {
            pointer = UnsafeMutablePointer<UInt64>(bitPattern: Int(MachinePointer.untaggedValue(address)))!
            }
        }
    
    required init(_ base:UnsafeMutableRawPointer,_ offset:Int)
        {
        address = UInt64(UInt(bitPattern: base)) + UInt64(offset)
        pointer = UnsafeMutablePointer<UInt64>(bitPattern: Int(MachinePointer.untaggedValue(address)))!
        }
    
    init(base:Int,offset:Int)
        {
        address = UInt64(UInt(bitPattern: base)) + UInt64(offset)
        pointer = UnsafeMutablePointer<UInt64>(bitPattern: Int(MachinePointer.untaggedValue(address)))!
        }
    
    convenience init(_ base:Int)
        {
        self.init(UInt64(base))
        }
    
   @inline(__always)
    public func header() -> ArgonInstanceHeaderField
        {
        if address == 0
            {
            return(ArgonInstanceHeaderField(word: 0))
            }
        return(ArgonInstanceHeaderField(word: pointer[0]))
        }
    
    public func tagAsInstance()
        {
        address |= MachinePointer.kTagInstance
        }
    
    public subscript(_ index:Int) -> UInt64
        {
        get
            {
            return(pointer[index])
            }
        set
            {
            pointer[index] = newValue
            }
        }
    }

public protocol MachineWordType
    {
    var machineWord:Int64 { get }
    init(_ uint64:UInt64)
    }

extension UInt64:MachineWordType
    {
    public var machineWord:Int64
        {
        return(Int64(self))
        }
    }


public func printBinaryWord(_ message:String,_ word:UInt64)
    {
    print("\(message) \(MachinePointer.bitString(of: word))")
    }

public func printHexWord(_ message:String,_ word:UInt64)
    {
    let string = String(format: "%0lX",word)
    print("\(message) \(string)")
    }

public func printDecimalWord(_ message:String,_ word:UInt64)
    {
    let string = String(format: "%0llu",word)
    print("\(message) \(string)")
    }
