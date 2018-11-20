//
//  MemoryViewController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa
import SharedMemory

class MemoryViewController: NSViewController
    {
    public static var shared:MemoryViewController?
    
    private let kSharedMemorySize = 4 * 1024 * 1024
    private let kSharedFromSegmentName = "/argon/memory/from"
    private let kSharedToSegmentName = "/argon/memory/to"
    
    @IBOutlet var fromSpace:MemoryBlockListView!
    @IBOutlet var toSpace:MemoryBlockListView!
    @IBOutlet var addressField:NSTextField!
    private var toSharedMemoryHandle:Int32 = -1
    private var toSharedMemoryPointer:UnsafeMutableRawPointer?
    private var fromSharedMemoryHandle:Int32 = -1
    private var fromSharedMemoryPointer:UnsafeMutableRawPointer?
    private var mustErase = false
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        MemoryViewController.shared = self
        do
            {
            try mapInMemory()
            }
        catch
            {
            print("Shared memory error")
            }
        }
    
    private func mapInMemory() throws
        {
        toSharedMemoryHandle = sharedMemoryOpen(kSharedToSegmentName)
        guard toSharedMemoryHandle != -1 else
            {
            print("Error accessing shared memory \(errno)")
            throw(ArgonInspectorError.sharedMemoryError)
            }
        toSharedMemoryPointer = mmap(nil,kSharedMemorySize,PROT_READ | PROT_WRITE,MAP_SHARED,toSharedMemoryHandle,0)
        guard Int(bitPattern: toSharedMemoryPointer) != -1 else
            {
            print("Attaching memory failed with \(errno)")
            throw(ArgonInspectorError.sharedMemoryError)
            }
        fromSharedMemoryHandle = sharedMemoryOpen(kSharedFromSegmentName)
        guard fromSharedMemoryHandle != -1 else
            {
            print("Error accessing shared memory \(errno)")
            throw(ArgonInspectorError.sharedMemoryError)
            }
        fromSharedMemoryPointer = mmap(nil,kSharedMemorySize,PROT_READ | PROT_WRITE,MAP_SHARED,fromSharedMemoryHandle,0)
        guard Int(bitPattern: fromSharedMemoryPointer) != -1 else
            {
            print("Attaching memory failed with \(errno)")
            throw(ArgonInspectorError.sharedMemoryError)
            }
        mustErase = true
        updateFromSharedMemory()
        }
    
    deinit
        {
        if mustErase
            {
            close(fromSharedMemoryHandle)
            close(toSharedMemoryHandle)
            }
        }
    
    @IBAction func onRefreshClicked(_ sender:Any?)
        {
        updateFromSharedMemory()
        }
    
    private func updateFromSharedMemory()
        {
        var pointer = UnsafePointer<UInt64>(bitPattern: Int(bitPattern: toSharedMemoryPointer))!
        var maxBytes = pointer[0]
        self.updateSpace(toPointer: toSharedMemoryPointer!, maximumOffset: Int(maxBytes), list: toSpace)
        pointer = UnsafePointer<UInt64>(bitPattern: Int(bitPattern: fromSharedMemoryPointer))!
        maxBytes = pointer[0]
        self.updateSpace(toPointer: fromSharedMemoryPointer!, maximumOffset: Int(maxBytes), list: fromSpace)
        }
    
    private func updateSpace(toPointer:UnsafeMutableRawPointer,maximumOffset:Int,list:MemoryBlockListView)
        {
        var rows:[ArgonInstanceElement] = []
        let pointer = UnsafePointer<UInt64>(bitPattern: Int(bitPattern: toPointer))!
        var index = 0
        index += 1 // adjust for packaging of shared memory
        let wordSize = MemoryLayout<UInt64>.size
        while (index*8) < maximumOffset && index < 1000
            {
            let headerWord = pointer[index]
            let header = ArgonInstanceHeaderField(word: headerWord)
            header.hexAddress = String(format: "%08X",(index - 2)*wordSize)
            print(" Header word \(MachinePointer.bitString(of: headerWord))")
            rows.append(header)
            header.address = Int(bitPattern:pointer) + index * wordSize
            index = index + 1
            if header.slotCount > 0
                {
                for _ in 1..<header.slotCount
                    {
                    let slotWord = pointer[index]
                    let field = ArgonSlotField(word: slotWord)
                    field.address = Int(bitPattern:pointer) + index * wordSize
                    rows.append(field)
                    index = index + 1
                    }
                index += header.extraWordCount
                }
            else
                {
                index += 1;
                }
            }
        list.list = rows
        }
    
    }
