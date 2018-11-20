//
//  ArgonTests.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/10.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonTests
    {
    public static func test()
        {
        do
            {
            testRelocationTags()
            try testDataSegment()
            testVMInstructions()
            testInvokingClosure()
            }
        catch
            {
            print("Error was \(error)")
            }
        }
    
    public static func testRelocationTags()
        {
        let offset:Word = 30677897
        let tagged = taggedRelocationOffset(offset)
        let untagged = untaggedRelocationOffset(tagged)
        assert(offset == untagged)
        }
    
    public static func testDataSegment() throws
        {
        let vm = try VirtualMachine()
        let memory = vm.memory!
        let dataSegment = memory.dataSegment
        let address = addressOfNextFreeWordsOfSizeInDataSegment(160, dataSegment)
        let word:Word = 397456
        setWordAtPointer(word,address)
        let newWord = wordAtPointer(address)
        assert(word == newWord)
        let threadMemory = allocateThreadMemoryWithCapacity(102*1024)
        for index:Word in 1...20
            {
            pushWord(threadMemory,index)
            }
        let rootArray = allocateRootArray()
        addStackContentsToRootArray(threadMemory, rootArray)
        for index:Word in stride(from:20,to:1,by:-1)
            {
            assert( index == popWord(threadMemory))
            }
        }
    
    public static func testVMInstructions()
        {
        let instruction1 = VMInstruction.MOV(immediate:23,into: VMRegister(.R0))
        instruction1.dump()
        let instruction2 = VMInstruction.MOV(address:47,into: VMRegister(.R9))
        instruction2.dump()
        let instruction3 = VMInstruction.PUSH(immediate:23,register: VMRegister(.R21))
        instruction3.dump()
        let instruction4 = VMInstruction.PRIM(immediate:22)
        instruction4.dump()
        let instruction5 = VMInstruction.ADD(register1: VMRegister(.R11),register2: VMRegister(.R12),register3: VMRegister(.R13))
        instruction5.dump()
        let instruction6 = VMInstruction.BRT(register1: VMRegister(.R29),immediate: 48)
        instruction6.dump()
        }
    
    public static func testInvokingClosure()
        {
        let someValue = 99
        let closure =
            {
            let newValue = someValue * 77
            print("\(newValue)")
            }
        var address:UnsafePointer<()->()>?
        withUnsafePointer(to: closure)
            {
            pointer in
            address = pointer
            }
        let oldAddress = unsafeBitCast(address,to: UInt.self)
        let someAddress = UnsafePointer<()->()>(bitPattern: oldAddress)
        someAddress!.pointee()
        }
    
    public static func testVectorAndGrowth() throws
        {
        let memory = try Memory(capacity: 200 * 1024 * 1024,dataCapacity: 200*1024*1024)
        let vector1 = VectorPointer(try memory.allocate(vectorWithCapacity: 20))
        let capacity = 20 * 3 / 2
        assert(vector1.capacity == capacity)
        var strings:[String] = []
        for index in 0..<20
            {
            let newString = "This is string number \(index)"
            strings.append(newString)
            try vector1.append(try memory.allocate(string: newString,lookupTraits: true))
            assert(vector1.count == index + 1)
            }
        for index in stride(from:19,to:0,by:-1)
            {
            let stringPointer = StringPointerWrapper(vector1.pointerItem(at: index))
            assert(stringPointer.string == strings[index])
            }
        // trigger a grow
        var newerStrings:[String] = []
        for index in 0...20
            {
            let newerString = "\(index)This is the last string"
            let newerStringPointer1 = try memory.allocate(string: newerString,lookupTraits: true)
            try vector1.append(newerStringPointer1)
            newerStrings.append(newerString)
            }
        assert(vector1.capacity > capacity)
        for index in 0+20..<0 + 20 + 20
            {
            let vectorString = StringPointerWrapper(vector1.pointerItem(at: index))
            assert(newerStrings[index-20] == vectorString.string)
            }
        }
    
    public static func testAssembler() 
        {
        do
            {
//            let instruction = try MachineInstruction(instruction: 0)
//            let constant = Int(12345678)
//            instruction.immediate = Int(constant)
//            assert(instruction.immediate == constant)
//            let negative = -12345678
//            instruction.immediate = negative
//            assert(instruction.immediate == negative)
//            instruction.address = Int(constant)
//            assert(instruction.address == constant)
//            instruction.address = Int(negative)
//            assert(instruction.address == negative)
//            let assembler = ArgonAssembler()
//            try assembler.open()
//            let label1 = assembler.newLabel()
//            try assembler.add(MachineInstruction.MOV(target:.GPR0,immediate:999).label(label1))
//            try assembler.add(MachineInstruction.PUSH(target:.BP))
//            try assembler.add(MachineInstruction.PUSH(target:.GPR0))
//            try assembler.add(MachineInstruction.PUSH(target:.FPR7))
//            try assembler.add(MachineInstruction.INC(target:.GPR19))
//            try assembler.add(MachineInstruction.DEC(target:.GPR19))
//            try assembler.add(MachineInstruction.INC(addressIndirect: 38960))
//            try assembler.add(MachineInstruction.DEC(addressIndirect: 38960))
//            let label2 = assembler.newLabel()
//            try assembler.add(MachineInstruction.CALL(label: label2))
//            try assembler.add(MachineInstruction.BR(offset: 2))
//            try assembler.add(MachineInstruction.NOP())
//            try assembler.add(MachineInstruction.INC(target:  .BP))
//            try assembler.add(MachineInstruction.MOV(target:.GPR0,immediate: 15))
//            try assembler.add(MachineInstruction.MOV(target:.GPR23,immediate: 7))
//            try assembler.add(MachineInstruction.AND(target: .GPR31,source1:.GPR23,source2:.GPR0))
//            try assembler.add(MachineInstruction.MOV(target:.GPR9,immediate: 10))
//            try assembler.add(MachineInstruction.MOV(target:.GPR10,immediate: 345))
//            try assembler.add(MachineInstruction.XOR(target:.GPR11,source1:.GPR9,source2:.GPR10))
//            try assembler.add(MachineInstruction.MOV(target:.GPR19,immediate: 47))
//            try assembler.add(MachineInstruction.MOV(target:.GPR20,immediate: 46))
//            try assembler.add(MachineInstruction.OR(target:.GPR22,source1:.GPR19,source2:.GPR20))
//            try assembler.add(MachineInstruction.MOV(target:.GPR29,immediate: 29))
//            try assembler.add(MachineInstruction.NOT(target:.GPR28,source1:.GPR29).label(label2))
//            try assembler.add(MachineInstruction.ENTER(4))
//            try assembler.add(MachineInstruction.MOV(targetIndirect:.BP,source1: .GPR26,immediate:-24))
//            try assembler.add(MachineInstruction.MOV(targetIndirect:.BP, source1:.GPR27,immediate:-0))
//            try assembler.add(MachineInstruction.MOV(targetIndirect:.BP,source1:.GPR12,immediate:+16))
//            try assembler.add(MachineInstruction.LEAVE(4))
//            try assembler.add(MachineInstruction.BR(label:label1))
//            try assembler.add(MachineInstruction.NOP())
//            try assembler.close()
//            let lines = try assembler.disassemble()
//            for line in lines
//                {
//                print(line)
//                }
            }
        catch
            {
            print("Error testing assembler \(error)")
            }
        }
    }
