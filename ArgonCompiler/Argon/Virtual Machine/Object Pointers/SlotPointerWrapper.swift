//
//  SlotPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class SlotPointerWrapper:InstancePointerWrapper
    {
    public var name:String
        {
        get
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(1,self.pointer))
            return(stringPointer.string)
            }
        set
            {
            let stringPointer = StringPointerWrapper(pointerAtIndexAtPointer(1,self.pointer))
            if newValue.count < stringPointer.capacity
                {
                stringPointer.string = newValue
                }
            }
        }
    
    public var slotIndex:Int
        {
        return(Int(self[3]))
        }
    }
