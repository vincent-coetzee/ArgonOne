//
//  ArgonInstanceHeaderField.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public typealias ArgonWord = UInt64

public class ArgonInstanceHeaderField:ArgonInstanceElement
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
    
    public static let kCleanAddressMask:UInt64 = ~(UInt64(7) << UInt64(60) | UInt64(1) << UInt64(59))
    public static let kTagMaskShift:UInt64 = UInt64(60)
    public static let kTagHeaderFlagValue = UInt64(5)
    public static let kTagHeader:UInt64 = UInt64(5) << UInt64(60)
    
    public override var cellIdentifier:String
        {
        return("InstanceHeaderCellView")
        }
    
    @inline(__always)
    public static func isForwarded(header:UInt64) -> Bool
        {
        return(header & kForwardedMask == kForwardedMask)
        }
    
    public static func type(of word: ArgonWord) -> String
        {
        let typeFlag = (ArgonInstanceHeaderField.kTypeFlagMask & word) >> ArgonInstanceHeaderField.kTypeFlagShift
        switch(Int(typeFlag))
            {
            case ArgonInstanceHeaderField.kTypeMap:
                return("Map")
            case ArgonInstanceHeaderField.kTypeHashBucket:
                return("Hashbucket")
            case ArgonInstanceHeaderField.kTypeSlot:
                return("Slot")
            case ArgonInstanceHeaderField.kTypeVector:
                return("Vector")
            case ArgonInstanceHeaderField.kTypeBitSet:
                return("BitSet")
            case ArgonInstanceHeaderField.kTypeMethod:
                return("Method")
            case ArgonInstanceHeaderField.kTypeString:
                return("String")
            case ArgonInstanceHeaderField.kTypeTraits:
                return("Traits")
            case ArgonInstanceHeaderField.kTypeSymbol:
                return("Symbol")
            default:
                return("Instance")
            }
        }
    
    public var hexAddress:String = ""
    
    public var slotCount:Int
        {
        get
            {
            let slots = (word & ArgonInstanceHeaderField.kSlotCountMask) >> ArgonInstanceHeaderField.kSlotCountShift
            return(Int(slots))
            }
        set
            {
            var newWord = word & ~ArgonInstanceHeaderField.kSlotCountMask
            newWord |= UInt64(newValue << ArgonInstanceHeaderField.kSlotCountShift)
            word = newWord
            }
        }
    
    public var headerTag:Bool
        {
        get
            {
            let slots = (word & ArgonInstanceElement.kTagMask) >> ArgonInstanceHeaderField.kTagMaskShift
            return(slots == ArgonInstanceHeaderField.kTagHeader >> ArgonInstanceHeaderField.kTagMaskShift)
            }
        set
            {
            word |= (newValue ? ArgonInstanceHeaderField.kTagHeader : 0)
            }
        }
    
    public var extraWordCount:Int
        {
        get
            {
            let extra = (word & ArgonInstanceHeaderField.kExtraWordCountMask) >> ArgonInstanceHeaderField.kExtraWordCountShift
            return(Int(extra))
            }
        set
            {
            var newWord = word & ~ArgonInstanceHeaderField.kExtraWordCountMask
            newWord |= UInt64(newValue << ArgonInstanceHeaderField.kExtraWordCountShift)
            word = newWord
            }
        }
    
    public var generation:Int
        {
        get
            {
            let count = (word & ArgonInstanceHeaderField.kGenerationMask) >> ArgonInstanceHeaderField.kGenerationShift
            return(Int(count))
            }
        set
            {
            var newWord = word & ~ArgonInstanceHeaderField.kGenerationMask
            newWord |= UInt64(newValue << ArgonInstanceHeaderField.kGenerationShift)
            word = newWord
            }
        }
    
    public var typeFlag:Int
        {
        get
            {
            let count = (word & ArgonInstanceHeaderField.kTypeFlagMask) >> ArgonInstanceHeaderField.kTypeFlagShift
            return(Int(count))
            }
        set
            {
            var newWord = word & ~ArgonInstanceHeaderField.kTypeFlagMask
            newWord |= UInt64(newValue << ArgonInstanceHeaderField.kTypeFlagShift)
            word = newWord
            }
        }
    
    public var typeName:String
        {
        switch(self.typeFlag)
            {
            case ArgonInstanceHeaderField.kTypeMap:
                return("Map")
            case ArgonInstanceHeaderField.kTypeHashBucket:
                return("Hashbucket")
            case ArgonInstanceHeaderField.kTypeSlot:
                return("Slot")
            case ArgonInstanceHeaderField.kTypeVector:
                return("Vector")
            case ArgonInstanceHeaderField.kTypeBitSet:
                return("BitSet")
            case ArgonInstanceHeaderField.kTypeMethod:
                return("Method")
            case ArgonInstanceHeaderField.kTypeString:
                return("String")
            case ArgonInstanceHeaderField.kTypeTraits:
                return("Traits")
            case ArgonInstanceHeaderField.kTypeSymbol:
                return("Symbol")
            default:
                return("Instance")
            }
        }
    
    public var forwardedFlag:Int
        {
        get
            {
            let count = (word & ArgonInstanceHeaderField.kForwardedMask) >> ArgonInstanceHeaderField.kForwardedShift
            return(Int(count))
            }
        set
            {
            var newWord = word & ~ArgonInstanceHeaderField.kForwardedMask
            newWord |= UInt64(newValue << ArgonInstanceHeaderField.kForwardedShift)
            word = newWord
            }
        }
    
    public var flags:Int
        {
        get
            {
            let count = (word & ArgonInstanceHeaderField.kFlagsMask) >> ArgonInstanceHeaderField.kFlagsShift
            return(Int(count))
            }
        set
            {
            var newWord = word & ~ArgonInstanceHeaderField.kFlagsMask
            newWord |= UInt64(newValue << ArgonInstanceHeaderField.kFlagsShift)
            word = newWord
            }
        }
        
    public func isType(_ type:Int) -> Bool
        {
        return(self.typeFlag & type == type)
        }
    
    public var totalInstanceSizeInWords:Int
        {
        return(self.slotCount + self.extraWordCount + 1)
        }
    
    public override func initCell(view:NSView?)
        {
        let actualCell = view as! InstanceHeaderCellView
        actualCell.wantsLayer = true
        actualCell.layer?.backgroundColor = NSColor.black.cgColor
        actualCell.headerField = self
        actualCell.hexAddress = hexAddress
        }

    public override func cellHeight() -> CGFloat
        {
        return(70)
        }
    }
