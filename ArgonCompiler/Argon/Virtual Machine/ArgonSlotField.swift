//
//  ArgonSlotField.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

//public class ArgonSlotField:ArgonInstanceElement
//    {
//    public static let kTagShift = UInt64(60)
//    
//    public override var cellIdentifier:String
//        {
//        return("SlotCellView")
//        }
//    
//    public var isTaggedValue:Bool
//        {
//        return((word & ArgonPointer.kTagMask >> ArgonSlotField.kTagShift) > 0)
//        }
//    
//    public var isPointer:Bool
//        {
//        let tag = word & ArgonPointer.kTagMask
//        return(tag == ArgonPointer.kTagInstance)
//        }
//    
//    public var slotObjectTypeName:String
//        {
//        if self.isTaggedValue
//            {
//            let tag = word & ArgonPointer.kTagMask
//            switch(tag)
//                {
//                case ArgonPointer.kTagInteger:
//                    return("Integer")
//                case ArgonPointer.kTagFloat:
//                    return("Float")
//                case ArgonPointer.kTagByte:
//                    return("Byte")
//                case ArgonPointer.kTagBoolean:
//                    return("Boolean")
//                case ArgonPointer.kTagInstance:
//                    return("Instance")
//                default:
//                    return("Other")
//                }
//            }
//        return("Native")
//        }
//    
//    public override func initCell(view:NSView?)
//        {
//        let actualCell = view as! SlotCellView
//        actualCell.value = ArgonInstanceElement.bitString(of: UInt(word))
//        if self.isTaggedValue
//            {
//            actualCell.label = self.slotObjectTypeName
//            }
//        else
//            {
//            actualCell.label = ""
//            }
//        }
//    
//    public override func cellHeight() -> CGFloat
//        {
//        return(20)
//        }
//    }
