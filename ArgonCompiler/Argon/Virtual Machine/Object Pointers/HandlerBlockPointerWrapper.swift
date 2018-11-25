//
//  HandlerBlockPointerWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/23.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class HandlerBlockPointerWrapper:InstancePointerWrapper
    {
    public static let kHandlerIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kInstructionBlockPointerIndex:Int32 = 3
    public static let kIPIndex:Int32 = 4
    public static let kLastHandlerBlockIndex:Int32 = 5
    
    public static let kFixedSlotCount = 6
    
    public static func allocate(count:Int,memory:Memory) throws -> HandlerBlockPointerWrapper
        {
        let traits = try memory.traits(atName:"Argon::HandlerBlock")
        let pointer = try memory.allocate(objectWithSlotCount: HandlerBlockPointerWrapper.kFixedSlotCount, traits: traits!, ofType: Argon.kTypeHandlerBlock)
        return(HandlerBlockPointerWrapper(pointer))
        }
    
    
    }
