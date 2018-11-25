//
//  GlobalMemoryReference.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/24.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class GlobalMemoryReference
    {
    public private(set) var name:String
    public private(set) var dataSegmentAddress:Pointer
    public private(set) var index:Int
    public var address:Pointer
    public var rootArrayIndex:Int = 0
    
    public init(name:String,dataSegmentAddress:Pointer,index:Int,address:Pointer)
        {
        self.name = name
        self.dataSegmentAddress = dataSegmentAddress
        self.index = index
        self.address = address
        }
    
    public func addToRootArray(rootArray:Pointer)
        {
        addRootToRootArray(Memory.kSourceData,Memory.kSourceThreadInvalid,index,address,rootArray)
        }
    }
