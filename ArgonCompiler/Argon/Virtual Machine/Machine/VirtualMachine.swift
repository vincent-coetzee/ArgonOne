//
//  VirtualMachine.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//
//
//
// FIRST LOCAL CAN BE FOUND AT SP[BP+2] GOING UP
// FIRST PARM CAN BE FOUND AT SP[BP+0] GOINF DOWN
//
import Foundation
import SharedMemory

public struct VMState
    {
    var IP:Int = 0
    var SP:Int = 0
    var BP:Int = 0
    var stack:[UInt64] = []
    var flagZero:Bool = false
    var flagEqual:Bool = false
    var flagLessThanEqual:Bool = false
    var flagLessThan:Bool = false
    var flagGreaterThan:Bool = false
    var flagGreaterThanEqual:Bool = false
    }



public class VirtualMachine
    {
    private static let kDataSegmentSize:Int32 = 128 * 1024 * 1024
    private static let kObjectMemorySize = 128 * 1024 * 1024
    private static let kThreadStorageSize:ArgonWord = 16 * 1024 * 1024
    
    private var globals:[UInt64] = []
    internal var memory:Memory!
    private var dataSegment:Pointer = wordAsPointer(0)
    private var sharedMemory = SharedMemoryManager()
    private var instructionPointer:Pointer = wordAsPointer(0)
    private var instructionCount:Int32 = 0
    public var threads:[VMThread] = []
    
    init() throws
        {
        try self.memory = Memory(capacity: Argon.kDefaultMemorySegmentSize, dataCapacity: Argon.kDefaultDataSegmentSize)
        self.dataSegment = memory.dataSegment
        print("Memory used for global roots = \(memory.spaceUsed)")
        }
    
    public func add(thread:VMThread)
        {
        threads.append(thread)
        }
    
    public func startMemoryMonitor() throws
        {
        
        sharedMemory = SharedMemoryManager()
        try sharedMemory.mapInMemory()
        sharedMemory.startWriteTimer(memory:memory)
        }
    }
