//
//  ArgonSharedMemoru.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class SharedMemoryManager
    {
    private static let kToSharedMemorySegmentName = "/argon/memory/to"
    private static let kFromSharedMemorySegmentName = "/argon/memory/from"
    
    private var toSharedMemoryHandle:Int32 = -1
    private var toSharedMemoryPointer:UnsafeMutableRawPointer?
    private var fromSharedMemoryHandle:Int32 = -1
    private var fromSharedMemoryPointer:UnsafeMutableRawPointer?
    private var timer:DispatchSourceTimer!
    private var queue:DispatchQueue!
    private var mustErase = false
    
    init()
        {
        }
    
    public func mapInMemory() throws
        {
        toSharedMemoryHandle = sharedMemoryOpen(SharedMemoryManager.kToSharedMemorySegmentName)
        guard toSharedMemoryHandle != -1 else
            {
            print("Error accessing shared memory \(errno)")
            throw(VirtualMachineSignal.sharedMemoryError)
            }
        ftruncate(toSharedMemoryHandle,Int64(Argon.kSharedMemorySize))
        toSharedMemoryPointer = mmap(nil,Argon.kSharedMemorySize,PROT_READ | PROT_WRITE,MAP_SHARED,toSharedMemoryHandle,0)
        guard Int(bitPattern:toSharedMemoryPointer) != -1 else
            {
            print("Attaching memory failed with \(errno)")
            throw(VirtualMachineSignal.sharedMemoryError)
            }
        fromSharedMemoryHandle = sharedMemoryOpen(SharedMemoryManager.kFromSharedMemorySegmentName)
        guard fromSharedMemoryHandle != -1 else
            {
            print("Error accessing shared memory \(errno)")
            throw(VirtualMachineSignal.sharedMemoryError)
            }
        ftruncate(fromSharedMemoryHandle,Int64(Argon.kSharedMemorySize))
        fromSharedMemoryPointer = mmap(nil,Argon.kSharedMemorySize,PROT_READ | PROT_WRITE,MAP_SHARED,fromSharedMemoryHandle,0)
        guard Int(bitPattern:fromSharedMemoryPointer) != -1 else
            {
            print("Attaching memory failed with \(errno)")
            throw(VirtualMachineSignal.sharedMemoryError)
            }
        mustErase = true
        }
    
    deinit
        {
        if mustErase
            {
            munmap(toSharedMemoryPointer,Argon.kSharedMemorySize)
            shm_unlink(SharedMemoryManager.kToSharedMemorySegmentName)
            munmap(fromSharedMemoryPointer,Argon.kSharedMemorySize)
            shm_unlink(SharedMemoryManager.kFromSharedMemorySegmentName)
            }
        }
    
    public func startWriteTimer(memory:Memory)
        {
        queue = DispatchQueue(label:"com.macsemantics.argon.memory.queue")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: DispatchTime.now(), repeating: .seconds(2), leeway: .milliseconds(200))
        timer.setEventHandler
            {
            memory.copyToSpace(size: Argon.kSharedMemorySize, to: self.toSharedMemoryPointer!)
            memory.copyFromSpace(size: Argon.kSharedMemorySize, to: self.fromSharedMemoryPointer!)
            }
        timer.resume()
        }
    }
