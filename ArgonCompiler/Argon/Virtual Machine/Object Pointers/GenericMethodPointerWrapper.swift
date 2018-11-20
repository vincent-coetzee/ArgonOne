//
//  GenericMethodPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/06.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class GenericMethodPointerWrapper:InstancePointerWrapper
    {
    public static let kHeaderIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kNameIndex:Int32 = 3
    public static let kParameterSlotCountIndex:Int32 = 4
    public static let kTreeIndex:Int32 = 5
    
    public static let kFixedSlotCount = 6
    
    public static let kInstanceTraitsIndex:Int32 = 1
    public static let kInstanceMonitorIndex:Int32 = 2
    public static let kInstanceParameterCountIndex:Int32 = 3
    public static let kInstanceCodeIndex:Int32 = 4
    public static let kInstanceParameterTypesIndex:Int32 = 5
    
    public var name:String
        {
        get
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(Int32(GenericMethodPointerWrapper.kNameIndex),self.pointer))
            return(stringPointer.string)
            }
        }
        
    public var selectionTreeRoot:GenericMethodNode
        {
        do
            {
            var index = Int32(GenericMethodPointerWrapper.kTreeIndex)
            let tree = try GenericMethodParentNode.read(from: self.pointer,index: &index)
            return(tree)
                }
            catch
                {
                print("\(error)")
                }
            return(GenericMethodParentNode(kindHolder: KindHolder()))
        }
    
    public var parameterCount:Int
        {
        return(Int(wordAtIndexAtPointer(GenericMethodPointerWrapper.kParameterSlotCountIndex,self.pointer)))
        }
    }
