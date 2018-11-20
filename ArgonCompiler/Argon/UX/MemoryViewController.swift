//
//  MemoryViewController.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class MemoryViewController: NSViewController
    {
    public static var shared:MemoryViewController?
    
    @IBOutlet var fromSpace:MemoryBlockListView!
    @IBOutlet var toSpace:MemoryBlockListView!
    @IBOutlet var addressField:NSTextField!
    
    @IBAction func onForceFlip(_ sender:Any?)
        {
//        do
//            {
//            try vm?.collectGarbage()
            self.updateSpaceLists()
//            }
//        catch
//            {
//            print("error \(error)")
//            }
        }

    private func updateSpaceLists()
        {
//        self.updateSpace(from: nil,toPointer:vm!.toSpacePointer,maximumOffset:memory.toSpaceOffset,list:toSpace)
//        self.updateSpace(from: nil,toPointer:vm!.fromSpacePointer,maximumOffset:memory.fromSpaceOffset,list:fromSpace)
        }
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        updateSpaceLists()
        }
    
    @IBAction func onRefreshClicked(_ sender:Any?)
        {
//        let address = addressField.stringValue
//        if  address.isEmpty
//            {
//            self.updateSpaceLists()
//            }
//        else
//            {
//            self.updateSpace(from: address,toPointer:memory.toSpacePointer,maximumOffset:memory.toSpaceOffset,list:toSpace)
//            self.updateSpace(from: address,toPointer:memory.fromSpacePointer,maximumOffset:memory.fromSpaceOffset,list:fromSpace)
//            }
        }
    
    public func updateSpace(from: String?,toPointer:UnsafeMutableRawPointer,maximumOffset:Int,list:MemoryBlockListView)
        {
//        guard from == nil else
//            {
//            return
//            }
//        var rows:[ArgonInstanceElement] = []
//        let pointer = UnsafePointer<UInt64>(bitPattern: UInt(bitPattern: toPointer))!
//        var index = 0
//        let wordSize = MemoryLayout<UInt64>.size
//        while (index*8) < maximumOffset
//            {
//            let headerWord = pointer[index]
//            let header = ArgonInstanceHeaderField(word: headerWord)
//            header.hexAddress = String(format: "%08X",(pointer + index).address - pointer.address)
//            rows.append(header)
//            header.address = Int(bitPattern:pointer) + index * wordSize
//            index += 1
//            for _ in 1..<header.slotCount
//                {
//                let slotWord = pointer[index]
//                let field = ArgonSlotField(word: slotWord)
//                field.address = Int(bitPattern:pointer) + index * wordSize
//                rows.append(field)
//                index = index + 1
//                }
//            index += header.extraWordCount
//            }
//        list.list = rows
        }
    }
