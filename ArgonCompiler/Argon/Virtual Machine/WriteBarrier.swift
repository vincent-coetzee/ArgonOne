//
//  WriteBarrier.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct WriteBarrier
    {
    private let kPageSize:UInt = 4096
    
    private let baseAddress:UInt
    private let capacityInBytes:UInt
    private var pages:[UInt] = []
    private var pagesCapacity:UInt = 0
    
    init(basePointer:UnsafeMutableRawPointer,capacity:UInt)
        {
        self.baseAddress = UInt(bitPattern: basePointer)
        self.capacityInBytes = capacity
        self.pagesCapacity = (((self.capacityInBytes / kPageSize) + 1) / 8) + 1
        self.pages = Array<UInt>(repeating: 0, count: Int(self.pagesCapacity))
        }
    
    init(baseAddress:UInt,capacity:UInt)
        {
        self.baseAddress = baseAddress
        self.capacityInBytes = capacity
        self.pagesCapacity = (((self.capacityInBytes / kPageSize) + 1) / 8) + 1
        self.pages = Array<UInt>(repeating: 0, count: Int(self.pagesCapacity))
        }
    
    func write(address:UInt64)
        {
//        let bitOffset = 
        }
    }
