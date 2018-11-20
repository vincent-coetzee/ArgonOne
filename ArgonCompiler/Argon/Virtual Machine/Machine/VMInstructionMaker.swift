//
//  VMInstructionMaker.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public func vmThreadRunner(_ value:UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?
    {
    let thread = value.bindMemory(to: VMThread.self, capacity: 1).pointee
    thread.run()
    return(nil)
    }

public typealias InstructionClosure = (VMThread) throws -> Void

public class VMInstructionMaker
    {
//    
//    @inline(__always)
//    private func MAKE(_ instruction:VMInstruction)
//        {
//
//            
//            let stringPointer = StringPointer(popPointer(thread.threadMemory))
//            let traitsName = stringPointer.string
//            let traitsPointer = try thread.memory.traits(atName: traitsName)
//            if let actualPointer = traitsPointer
//                {
//                let pointer = TraitsPointer(actualPointer)
//                let totalSlots = pointer.slotCount
//                let instance = try thread.memory.allocate(objectWithSlotCount: totalSlots, traits: actualPointer, ofType: Argon.kTypeInstance)
//                thread.registers[(MachineRegister.R0.rawValue)] = ArgonWord(pointerAsWord(instance))
//                return
//                }
//            thread.registers[(MachineRegister.R0.rawValue)] = 0
//            
//        }
//    
//    @inline(__always)
//    private class func traits(of list:[ArgonWord],in thread:VMThread) throws -> [TraitsPointer]
//        {
//        var traits:[TraitsPointer] = []
//        for item in list
//            {
//            let tag = tagOfWord(item)
//            if tag == Argon.kTagInteger
//                {
//                traits.append(TraitsPointer(try thread.memory.traits(atName: "Integer")!))
//                }
//            else if tag == Argon.kTagFloat
//                {
//                traits.append(TraitsPointer(try thread.memory.traits(atName: "Float")!))
//                }
//            else if tag == Argon.kTagByte
//                {
//                traits.append(TraitsPointer(try thread.memory.traits(atName: "Byte")!))
//                }
//            else if tag == Argon.kTagInstance
//                {
//                traits.append(TraitsPointer(pointerAtIndexAtPointer(1,wordAsPointer(item))))
//                }
//            }
//        return(traits)
//        }
//    
//    @inline(__always)
//    private func DSP(_ instruction:VMInstruction)
//        {
//        let register = instruction.register1.rawValue
//
//            
//            let addressOfGeneric = thread.registers[register]
//            let genericPointer = GenericMethodPointer(wordAsPointer(addressOfGeneric))
//            var parameters:[ArgonWord] = []
//            for _ in 0..<genericPointer.parameterCount
//                {
//                parameters.append(ArgonWord(popWord(thread.threadMemory)))
//                }
//            let traits = try VMInstructionMaker.traits(of: parameters,in: thread)
//            guard let methodPointer = genericPointer.selectionTreeRoot.select(from: traits) else
//                {
//                throw(VirtualMachineSignal.dispatchFailed)
//                }
//            let codePointer = incrementPointerBy(pointerAtIndexAtPointer(MethodPointer.kCodeBlockIndex,methodPointer),CodeBlockPointer.kInstructionsIndex)
//            pushPointer(thread.threadMemory,thread.codeBlockInstructionPointer)
//            pushWord(thread.threadMemory,Word(thread.IP))
//            thread.codeBlockInstructionPointer = codePointer
//            thread.IP = 0
//            
//        }
//    
//    @inline(__always)
//    private func AND(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] & thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func STORE(_ instruction:VMInstruction)
//        {
//
//            
//            if instruction.mode == .rightIndirect
//                {
//                let address = ArgonWord(instruction.immediate) + thread.registers[instruction.register2.rawValue]
//                setWordAtIndexAtPointer(thread.registers[instruction.register1.rawValue],0,wordAsPointer(address))
//                }
//            
//        }
//    
//    @inline(__always)
//    private func LOAD(_ instruction:VMInstruction)
//        {
//        let immediate = instruction.immediate
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//
//            
//            if instruction.mode == .rightIndirect
//                {
//                let address = ArgonWord(immediate) + thread.registers[register2]
//                setWordAtIndexAtPointer(thread.registers[register1],0,wordAsPointer(address))
//                }
//            
//        }
//    
//    @inline(__always)
//    private func OR(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] | thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func XOR(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] ^ thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func ADD(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] + thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func SUB(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] - thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func MUL(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] * thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func DIV(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] / thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func MOD(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            thread.registers[register3] = thread.registers[register1] % thread.registers[register2]
//            
//        }
//    
//    @inline(__always)
//    private func NOT(_ instruction:VMInstruction)
//        {
//
//            
//            thread.registers[instruction.register2.rawValue] = ~thread.registers[instruction.register1.rawValue]
//            
//        }
//    
//    @inline(__always)
//    private func NOP(_ instruction:VMInstruction)
//        {
//        return({ })
//        }
//    
//    @inline(__always)
//    private func CALL(_ instruction:VMInstruction)
//        {
//        let immediate = Int32(instruction.immediate)
//        let register1 = instruction.register1.rawValue
//
//            
//            let aMode = instruction.mode
//            if aMode == .immediate
//                {
//                pushPointer(thread.threadMemory,thread.codeBlockInstructionPointer)
//                pushWord(thread.threadMemory,Word(thread.IP))
//                thread.IP = Int32(thread.IP) + immediate
//                }
//            else if aMode == .indirect
//                {
//                let address = wordAsPointer(thread.registers[register1] + ArgonWord(immediate))
//                pushPointer(thread.threadMemory,thread.codeBlockInstructionPointer)
//                pushWord(thread.threadMemory,Word(thread.IP))
//                thread.IP = Int32(ArgonWord(thread.IP) + ArgonWord(wordAtIndexAtPointer(0,address)))
//                }
//            
//        }
//    
//    @inline(__always)
//    private func RET(_ instruction:VMInstruction)
//        {
//
//            
//            thread.IP = Int32(popWord(thread.threadMemory))
//            thread.codeBlockInstructionPointer = popPointer(thread.threadMemory)
//            
//        }
//    
//    @inline(__always)
//    private func BRT(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let immediate = instruction.immediate
//
//            
//            if thread.registers[register1] == 1
//                {
//                thread.IP += Int32(immediate)
//                }
//            
//        }
//    
//    @inline(__always)
//    private func BRF(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//
//            
//            if thread.registers[register1] == 0
//                {
//                thread.IP += Int32(instruction.immediate)
//                }
//            
//        }
//    
//    @inline(__always)
//    private func EQ(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            if thread.registers[register1] == thread.registers[register2]
//                {
//                thread.registers[register3] = 1
//                }
//            else
//                {
//                thread.registers[register3] = 0
//                }
//            
//        }
//    
//    @inline(__always)
//    private func SPAWN(_ instruction:VMInstruction)
//        {
//
//            
//            let closureAddress = instruction.addressWord
//            let closurePointer = ClosurePointer(wordAsPointer(closureAddress))
//            let closureCodeBlock = closurePointer.codeBlockPointer
//            let newThread = VMThread(vm: thread.vm, codeBlock: closureCodeBlock.pointer, IP: 0, memory: thread.memory, dataSegment: thread.dataSegment, capacity: ArgonWord(Argon.kDefaultThreadMemorySize))
//            thread.vm.add(thread: newThread)
//            newThread.IP = 0
//            let threadTypePointer = UnsafeMutablePointer<pthread_t?>.allocate(capacity: 1)
//            defer
//                {
//                threadTypePointer.deallocate()
//                }
//            let argument = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<VMThread>.size, alignment:  MemoryLayout<VMThread>.alignment)
//            defer
//                {
//                argument.deallocate()
//                }
//            let threadPointer = argument.bindMemory(to: VMThread.self, capacity: 1)
//            threadPointer.pointee = newThread
//            let newArgument = UnsafeMutableRawPointer(threadPointer)
//            pthread_create(threadTypePointer, nil,vmThreadRunner,newArgument)
//            thread.pthread = threadTypePointer.pointee
//            
//        }
//    
//    @inline(__always)
//    private func LTE(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            if thread.registers[register1] <= thread.registers[register2]
//                {
//                thread.registers[register3] = 1
//                }
//            else
//                {
//                thread.registers[register3] = 0
//                }
//            
//        }
//    
//    @inline(__always)
//    private func LT(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            if thread.registers[register1] < thread.registers[register2]
//                {
//                thread.registers[register3] = 1
//                }
//            else
//                {
//                thread.registers[register3] = 0
//                }
//            
//        }
//    
//    @inline(__always)
//    private func GT(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            if thread.registers[register1] > thread.registers[register2]
//                {
//                thread.registers[register3] = 1
//                }
//            else
//                {
//                thread.registers[register3] = 0
//                }
//            
//        }
//    
//    @inline(__always)
//    private func GTE(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let register3 = instruction.register3.rawValue
//
//            
//            if thread.registers[register1] >= thread.registers[register2]
//                {
//                thread.registers[register3] = 1
//                }
//            else
//                {
//                thread.registers[register3] = 0
//                }
//            
//        }
//    
//    internal func collectGarbage() throws
//        {
//        let timer = Timer()
//        let milliseconds = timer.stop()
//        print("GC took \(milliseconds) ms")
//        }
//    
//    @inline(__always)
//    private func MOVAR(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//
//            
//            let address = instruction.addressWord
//            thread.registers[register1] = address
//            
//        }
//    
//    @inline(__always)
//    private func MOVIR(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let immediate = ArgonWord(instruction.immediate)
//
//            
//            thread.registers[register1] = immediate
//            
//        }
//    @inline(__always)
//    private func MOVRR(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//
//            
//            thread.registers[register2] = thread.registers[register1]
//            
//        }
//    
//    @inline(__always)
//    private func MOVNR(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let immediate = Int64(instruction.immediate)
//
//            
//            let value = Int64(thread.registers[register1]) + immediate
//            thread.registers[register2] = wordAtIndexAtPointer(0,wordAsPointer(UInt64(value)))
//            
//        }
//    
//    @inline(__always)
//    private func MOVRN(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let register2 = instruction.register2.rawValue
//        let immediate = Int64(instruction.immediate)
//
//            
//            let value = Int64(thread.registers[register2]) + immediate
//            setWordAtIndexAtPointer(thread.registers[register1],0,wordAsPointer(UInt64(value)))
//            
//        }
//    
//   @inline(__always)
//    private func PRIM(_ instruction:VMInstruction)
//        {
//        let number = instruction.immediate
//
//            
//            print("SELF PERFORM PRIMITIVE \(number)")
//            
//        }
//    
//    @inline(__always)
//    private func INC(_ instruction:VMInstruction)
//        {
//        let mode = instruction.mode
//        let register1 = instruction.register1.rawValue
//        let immediate = ArgonWord(instruction.immediate)
//
//            
//            if mode == .register
//                {
//                thread.registers[register1] += 1
//                }
//            else if mode == .indirect
//                {
//                let pointer = wordAsPointer(immediate + thread.registers[register1])
//                let value = wordAtIndexAtPointer(0,pointer) + 1
//                setWordAtIndexAtPointer(value,0,pointer)
//                }
//            
//        }
//    
//    @inline(__always)
//    private func DEC(_ instruction:VMInstruction)
//        {
//        let mode = instruction.mode
//        let register1 = instruction.register1.rawValue
//        let immediate = ArgonWord(instruction.immediate)
//
//            
//            if mode == .register
//                {
//                thread.registers[register1] -= 1
//                }
//            else if mode == .indirect
//                {
//                let pointer = wordAsPointer(immediate + thread.registers[register1])
//                let value = wordAtIndexAtPointer(0,pointer) - 1
//                setWordAtIndexAtPointer(value,0,pointer)
//                }
//            
//        }
//    
//    @inline(__always)
//    private func BR(_ instruction:VMInstruction)
//        {
//        let immediate = Int32(instruction.immediate)
//
//            
//            if thread.IP + immediate >= Int32(thread.instructionCount)
//                {
//                throw(VirtualMachineFault.invalidAddress)
//                }
//            thread.IP += immediate
//            
//        }
//    
//    @inline(__always)
//    private func PUSH(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let immediate = Int64(instruction.immediate)
//        let mode = instruction.mode
//
//            
//            switch(mode)
//                {
//                case .register:
//                    pushWord(thread.threadMemory,thread.registers[register1])
//                case .indirect:
//                    let address = Int64(thread.registers[register1]) + immediate
//                    pushWord(thread.threadMemory,wordAtIndexAtPointer(0,wordAsPointer(UInt64(address))))
//                default:
//                    throw(VirtualMachineSignal.invalidInstruction)
//                }
//            
//        }
//    
//    @inline(__always)
//    private func POP(_ instruction:VMInstruction)
//        {
//        let register1 = instruction.register1.rawValue
//        let immediate = ArgonWord(instruction.immediate)
//        let mode = instruction.mode
//
//            
//            if mode == .register
//                {
//                thread.registers[register1] = ArgonWord(popWord(thread.threadMemory))
//                }
//            else if mode == .indirect
//                {
//                let pointer = wordAsPointer(immediate + thread.registers[register1])
//                setWordAtIndexAtPointer(popWord(thread.threadMemory), 0, pointer)
//                }
//            else
//                {
//                throw(VirtualMachineSignal.invalidInstruction)
//                }
//            
//        }
    }

