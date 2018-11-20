//
//  VMThread.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class VMThread:AbstractModel
    {
    public static let kFlagZeroBit = 1
    public static let kFlagLessThanBit = 2
    public static let kFlagLessThanEqualBit = 4
    public static let kFlagEqualBit = 8
    public static let kFlagGreaterThanBit = 16
    public static let kFlagGreaterThanEqualBit = 32
    public static let kFlagNotEqualBit = 64
    public static let kFlagNotZeroBit = 128
    
    public private(set) var threadMemory:UnsafeMutablePointer<VMThreadMemory>
    public var codeBlockInstructionPointer:Pointer
    public private(set) var memory:Memory
    public private(set) var dataSegment:Pointer
    public private(set) var instructionCount:Int
    public private(set) var vm:VirtualMachine
    public private(set) var key:Int
    public private(set) var codeBlockPointer:CodeBlockPointerWrapper
    public private(set) var codeBlockInstructionCount:Int = 0
    public var pthread:pthread_t?
    
    public var IP:Int32 = 0
    public var conditions:ArgonWord = 0

    private var isInSimulator = true
    
    init(vm:VirtualMachine,codeBlock:Pointer,IP:Int,capacity:ArgonWord)
        {
        self.codeBlockPointer = CodeBlockPointerWrapper(codeBlock)
        self.codeBlockInstructionPointer = codeBlockPointer.instructionPointer
        self.codeBlockInstructionCount = codeBlockPointer.instructionCount
        self.instructionCount = codeBlockPointer.instructionCount
        threadMemory = allocateThreadMemoryWithCapacity(capacity)
        print("AFTER ST ALLOCATION TP=\(threadRegisterPointerValue(threadMemory,MachineRegister.ST.rawValue)) SP=\(threadRegisterPointerValue(threadMemory,MachineRegister.SP.rawValue))")
        self.memory = vm.memory
        self.dataSegment = vm.memory.dataSegment
        self.vm = vm
        self.key = Argon.nextCounter
        }
    
    deinit
        {
        freeThreadMemory(self.threadMemory)
        }
    
    public func run()
        {
        do
            {
            while IP < codeBlockInstructionCount
                {
                let instruction = VMInstruction(wordAtIndexAtPointer(IP,codeBlockInstructionPointer))
                IP += 1
                if instruction.mode == .address
                    {
                    instruction.addressWord = wordAtIndexAtPointer(IP,codeBlockInstructionPointer)
                    IP += 1
                    }
                try self.dispatch(instruction:instruction)
                }
            }
        catch VirtualMachineFault.outOfMemory
            {
            self.memory.collectGarbage(vm.threads)
            }
        catch
            {
            print("Exception \(error) in thread \(key)")
            }
        }
    
    public func singleStep()
        {
        do
            {
            if IP < codeBlockInstructionCount
                {
                let instruction = VMInstruction(wordAtIndexAtPointer(IP,codeBlockInstructionPointer))
                IP += 1
                if instruction.mode == .address
                    {
                    instruction.addressWord = wordAtIndexAtPointer(IP,codeBlockInstructionPointer)
                    IP += 1
                    }
                try self.dispatch(instruction:instruction)
                }
            }
        catch VirtualMachineFault.outOfMemory
            {
            self.memory.collectGarbage(vm.threads)
            }
        catch
            {
            print("Exception \(error) in thread \(key)")
            }
        }
    
    private func dispatch(instruction:VMInstruction) throws
        {
        instruction.dump()
        switch(instruction.operation)
                {
                case .MAKE:
                    try self.MAKE(instruction)
                case .DSP:
                    try self.DSP(instruction)
                case .AND:
                    try self.AND(instruction)
                case .OR:
                    try self.OR(instruction)
                case .XOR:
                    try self.XOR(instruction)
                case .NOT:
                    try self.NOT(instruction)
                case .ADD:
                    try self.ADD(instruction)
                case .SUB:
                    try self.SUB(instruction)
                case .MOD:
                    try self.MOD(instruction)
                case .MUL:
                    try self.MUL(instruction)
                case .DIV:
                    try self.DIV(instruction)
                case .MOVAR:
                    try self.MOVAR(instruction)
                case .MOVIR:
                    try self.MOVIR(instruction)
                case .MOVNR:
                    try self.MOVNR(instruction)
                case .MOVRN:
                    try self.MOVRN(instruction)
                case .MOVRR:
                    try self.MOVRR(instruction)
                case .BR:
                    try self.BR(instruction)
                case .BRT:
                    try self.BRT(instruction)
                case .BRF:
                    try self.BRF(instruction)
                case .LT:
                    try self.LT(instruction)
                case .LTE:
                    try self.LTE(instruction)
                case .GT:
                    try self.GT(instruction)
                case .GTE:
                    try self.GTE(instruction)
                case .EQ:
                    try self.EQ(instruction)
                case .PUSH:
                    try self.PUSH(instruction)
                case .POP:
                    try self.POP(instruction)
                case .LOAD:
                    try self.STORE(instruction)
                case .STORE:
                    try self.LOAD(instruction)
                case .NOP:
                    try self.NOP(instruction)
                case .CALL:
                    try self.CALL(instruction)
                case .RET:
                    try self.RET(instruction)
                case .PRIM:
                    try self.PRIM(instruction)
                case .INC:
                    try self.INC(instruction)
                case .DEC:
                    try self.DEC(instruction)
                case .SPAWN:
                    try self.SPAWN(instruction)
                default:
                    print("OPCODE \(instruction.operation) NOT IMPLEMENTED")
                    throw(LinkerError.opcodeNotImplemented)
                }
        }
    
    public func addRegistersContainingPointerToRootArray(_ rootArray:UnsafeMutableRawPointer)
        {
        for index in 1..<Int(threadRegisterCount(self.threadMemory))
            {
            let value = threadRegisterWordValue(self.threadMemory,index)
            if isTaggedWord(value)
                {
                addRootFromSourceToRootArray(wordAsPointer(value),Memory.kSourceThreadRegister,unsafeBitCast(self,to: Pointer.self),Int32(index),rootArray)
                }
            }
        }
    
    @inline(__always)
    private func MAKE(_ instruction:VMInstruction) throws
        {
        let parmCount = instruction.immediate
        var count:Word = 0
        if parmCount == 2
            {
            count = popWord(self.threadMemory)
            }
        let address = popPointer(self.threadMemory)
        if let vectorPointer = try self.memory.traits(atName: "Argon::Vector"),address == vectorPointer
            {
            setThreadRegisterPointerValue(self.threadMemory,MachineRegister.R0.rawValue,try self.memory.allocate(vectorWithCapacity: Int(count)))
            return
            }
        else
            {
            let traits = TraitsPointerWrapper(address)
            let totalSlots = traits.slotCount + Int(count)
            let instance = try self.memory.allocate(objectWithSlotCount: totalSlots, traits: address, ofType: Argon.kTypeInstance)
            setThreadRegisterPointerValue(self.threadMemory,MachineRegister.R0.rawValue,instance)
            return
            }
        }
    
    @inline(__always)
    private func traits(of list:[ArgonWord],in thread:VMThread) throws -> [TraitsPointerWrapper]
        {
        var traits:[TraitsPointerWrapper] = []
        for item in list
            {
            let tag = tagOfWord(item)
            if tag == Argon.kTagInteger
                {
                traits.append(TraitsPointerWrapper(try thread.memory.traits(atName: "Argon::Integer")!))
                }
            else if tag == Argon.kTagFloat
                {
                traits.append(TraitsPointerWrapper(try thread.memory.traits(atName: "Argon::Float")!))
                }
            else if tag == Argon.kTagByte
                {
                traits.append(TraitsPointerWrapper(try thread.memory.traits(atName: "Argon::Byte")!))
                }
            else if tag == Argon.kTagInstance
                {
                traits.append(TraitsPointerWrapper(pointerAtIndexAtPointer(1,wordAsPointer(item))))
                }
            }
        return(traits)
        }
    
    @inline(__always)
    private func DSP(_ instruction:VMInstruction) throws
        {
        let addressOfGeneric = instruction.addressWord
        let genericPointer = GenericMethodPointerWrapper(wordAsPointer(addressOfGeneric))
        var parameters:[ArgonWord] = []
        for _ in 0..<genericPointer.parameterCount
            {
            parameters.append(ArgonWord(popWord(self.threadMemory)))
            }
        let traits = try self.traits(of: parameters,in: self)
        guard let methodPointer = genericPointer.selectionTreeRoot.select(from: traits) else
            {
            throw(VirtualMachineSignal.dispatchFailed)
            }
        let mainPointer = MethodPointerWrapper(methodPointer)
        let codeBlockPointer = mainPointer.codeBlock
        pushPointer(self.threadMemory,self.codeBlockInstructionPointer)
        pushWord(self.threadMemory,Word(self.IP))
        pushWord(self.threadMemory,Word(self.codeBlockInstructionCount))
        self.codeBlockInstructionPointer = codeBlockPointer.instructionPointer
        self.codeBlockInstructionCount = codeBlockPointer.instructionCount
        self.IP = 0
        if isInSimulator
            {
            self.changed(aspect: "thread.codeLocation",with: (self.codeBlockInstructionPointer,self.codeBlockInstructionCount,self.IP),from: self)
            }
        }
    
    @inline(__always)
    private func AND(_ instruction:VMInstruction)  throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) | threadRegisterWordValue(self.threadMemory,register2))
        }
    
    @inline(__always)
    private func STORE(_ instruction:VMInstruction) throws
        {
        let mode = instruction.mode
        if mode == .address
            {
            let address = instruction.addressWord
            let value = threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue)
            setWordAtIndexAtPointer(value,0,wordAsPointer(address))
            }
        else if mode == .immediate
            {
            let address = instruction.immediate
            let value = threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue)
            setWordAtOffsetInDataSegment(value,Int32(address),dataSegment)
            }
        else if mode == .register
            {
            let address = addressOfNextFreeWordsOfSizeInDataSegment(Int32(MemoryLayout<Word>.size), dataSegment)
            setWordAtIndexAtPointer(threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue),0,address)
            setThreadRegisterPointerValue(self.threadMemory,instruction.register2.rawValue,address)
            }
        }
    
    @inline(__always)
    private func LOAD(_ instruction:VMInstruction) throws
        {
        let immediate = instruction.immediate
        let register1 = instruction.register1.rawValue
        let mode = instruction.mode
        if mode == .address
            {
            let address = instruction.addressWord
            setThreadRegisterWordValue(self.threadMemory,register1,wordAtIndexAtPointer(0,wordAsPointer(address)))
            }
        else if mode == .immediate
            {
            setThreadRegisterWordValue(self.threadMemory,register1,wordAtIndexAtPointer(Int32(immediate),dataSegment))
            }
        }
    
    @inline(__always)
    private func OR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) | threadRegisterWordValue(self.threadMemory,register2))
        }
    
    @inline(__always)
    private func XOR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) ^ threadRegisterWordValue(self.threadMemory,register2))
        }
    
    @inline(__always)
    private func ADD(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        if instruction.mode == .immediate
            {
            setThreadRegisterWordValue(self.threadMemory,register2,threadRegisterWordValue(self.threadMemory,register1) + Word(instruction.immediate))
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) + threadRegisterWordValue(self.threadMemory,register2))
            }
        }
    
    @inline(__always)
    private func SUB(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        if instruction.mode == .immediate
            {
            setThreadRegisterWordValue(self.threadMemory,register2,threadRegisterWordValue(self.threadMemory,register1) - Word(instruction.immediate))
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) - threadRegisterWordValue(self.threadMemory,register2))
            }
        }
    
    @inline(__always)
    private func MUL(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) * threadRegisterWordValue(self.threadMemory,register2))
        }
    
    @inline(__always)
    private func DIV(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) / threadRegisterWordValue(self.threadMemory,register2))
        }
    
    @inline(__always)
    private func MOD(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        setThreadRegisterWordValue(self.threadMemory,register3,threadRegisterWordValue(self.threadMemory,register1) % threadRegisterWordValue(self.threadMemory,register2))
        }
    
    @inline(__always)
    private func NOT(_ instruction:VMInstruction) throws
        {
        let register2 = instruction.register2.rawValue
        setThreadRegisterWordValue(self.threadMemory,register2,threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue))
        }
    
    @inline(__always)
    private func NOP(_ instruction:VMInstruction) throws
        {
        }
    
    @inline(__always)
    private func CALL(_ instruction:VMInstruction) throws
        {
        let immediate = Int32(instruction.immediate)
        let register1 = instruction.register1.rawValue
        let aMode = instruction.mode
        if aMode == .immediate
            {
            pushPointer(self.threadMemory,self.codeBlockInstructionPointer)
            pushWord(self.threadMemory,Word(self.IP))
            self.IP = Int32(self.IP) + immediate
            }
        else if aMode == .indirect
            {
            let address = wordAsPointer(threadRegisterWordValue(self.threadMemory,register1) + Word(immediate))
            pushPointer(self.threadMemory,self.codeBlockInstructionPointer)
            pushWord(self.threadMemory,Word(self.IP))
            self.IP = Int32(ArgonWord(self.IP) + ArgonWord(wordAtIndexAtPointer(0,address)))
            }
        if isInSimulator
            {
            self.changed(aspect: "thread.codeLocation",with: (self.codeBlockInstructionPointer,self.codeBlockInstructionCount,self.IP),from: self)
            }
        }
    
    @inline(__always)
    private func RET(_ instruction:VMInstruction) throws
        {
        self.codeBlockInstructionCount = Int(popWord(self.threadMemory))
        self.IP = Int32(popWord(self.threadMemory))
        self.codeBlockInstructionPointer = popPointer(self.threadMemory)
        if isInSimulator
            {
            self.changed(aspect: "thread.codeLocation",with: (self.codeBlockInstructionPointer,self.codeBlockInstructionCount,self.IP),from: self)
            }
        }
    
    @inline(__always)
    private func BRT(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let immediate = instruction.immediate
        if threadRegisterWordValue(self.threadMemory,register1) == 1
            {
            self.IP += Int32(immediate)
            }
        }
    
    @inline(__always)
    private func BRF(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        if threadRegisterWordValue(self.threadMemory,register1) == 0
            {
            self.IP += Int32(instruction.immediate)
            }
        }
    
    @inline(__always)
    private func EQ(_ instruction:VMInstruction) throws
        {
        if threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue) == threadRegisterWordValue(self.threadMemory,instruction.register2.rawValue)
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,1)
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,0)
            }
        }
    
    @inline(__always)
    private func SPAWN(_ instruction:VMInstruction) throws
        {
        let closureAddress = instruction.addressWord
        let closurePointer = ClosurePointerWrapper(wordAsPointer(closureAddress))
        let closureCodeBlockPointer = closurePointer.codeBlockPointer
        let newThread = VMThread(vm: self.vm, codeBlock: closureCodeBlockPointer, IP: 0,capacity: ArgonWord(Argon.kDefaultThreadMemorySize))
        self.vm.add(thread: newThread)
        newThread.IP = 0
        let threadTypePointer = UnsafeMutablePointer<pthread_t?>.allocate(capacity: 1)
        defer
            {
            threadTypePointer.deallocate()
            }
        let argument = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<VMThread>.size, alignment:  MemoryLayout<VMThread>.alignment)
        defer
            {
            argument.deallocate()
            }
        let threadPointer = argument.bindMemory(to: VMThread.self, capacity: 1)
        threadPointer.pointee = newThread
        let newArgument = UnsafeMutableRawPointer(threadPointer)
        pthread_create(threadTypePointer, nil,vmThreadRunner,newArgument)
        self.pthread = threadTypePointer.pointee
        }
    
    @inline(__always)
    private func LTE(_ instruction:VMInstruction) throws
        {
        if threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue) <= threadRegisterWordValue(self.threadMemory,instruction.register2.rawValue)
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,1)
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,0)
            }
        }
    
    @inline(__always)
    private func LT(_ instruction:VMInstruction) throws
        {
        if threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue) < threadRegisterWordValue(self.threadMemory,instruction.register2.rawValue)
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,1)
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,0)
            }
        }
    
    @inline(__always)
    private func GT(_ instruction:VMInstruction) throws
        {
        if threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue) > threadRegisterWordValue(self.threadMemory,instruction.register2.rawValue)
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,1)
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,0)
            }
        }
    
    @inline(__always)
    private func GTE(_ instruction:VMInstruction) throws
        {
        if threadRegisterWordValue(self.threadMemory,instruction.register1.rawValue) >= threadRegisterWordValue(self.threadMemory,instruction.register2.rawValue)
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,1)
            }
        else
            {
            setThreadRegisterWordValue(self.threadMemory,instruction.register3.rawValue,0)
            }
        }
    
    internal func collectGarbage() throws
        {
        let timer = Timer()
        let milliseconds = timer.stop()
        print("GC took \(milliseconds) ms")
        }
    
    @inline(__always)
    private func MOVAR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let address = instruction.addressWord
        setThreadRegisterWordValue(self.threadMemory,register1,address)
        }
    
    @inline(__always)
    private func MOVIR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let immediate = ArgonWord(instruction.immediate)
        setThreadRegisterWordValue(self.threadMemory,register1,Word(immediate))
        }
    @inline(__always)
    private func MOVRR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        setThreadRegisterWordValue(self.threadMemory,register2,threadRegisterWordValue(self.threadMemory,register1))
        }
    
    @inline(__always)
    private func MOVNR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let immediate = Int64(instruction.immediate)
        let value = Int(threadRegisterWordValue(self.threadMemory,register1)) + Int(immediate)
        setThreadRegisterWordValue(self.threadMemory,register2,wordAtIndexAtPointer(0,wordAsPointer(Word(value))))
        }
    
    @inline(__always)
    private func MOVRN(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let immediate = instruction.immediate
        let value = Word(Int(threadRegisterWordValue(self.threadMemory,register2)) + Int(immediate))
        setWordAtIndexAtPointer(threadRegisterWordValue(self.threadMemory,register1),0,wordAsPointer(value))
        }
    
    fileprivate enum Primitive:Int
        {
        case print = 1
        }
    
   @inline(__always)
    private func PRIM(_ instruction:VMInstruction) throws
        {
        let number = instruction.immediate
        guard let prim = Primitive(rawValue: number) else
            {
            throw(RuntimeError.invalidPrimitive)
            }
            
        switch(prim)
            {
            case Primitive.print:
                self.primitivePrint(popPointer(self.threadMemory))
            }
        }
    
    private func primitivePrint(_ pointer:Pointer)
        {

        }
    
    @inline(__always)
    private func INC(_ instruction:VMInstruction) throws
        {
        let mode = instruction.mode
        let register1 = instruction.register1.rawValue
        let immediate = ArgonWord(instruction.immediate)
        if mode == .register
            {
            incrementThreadRegisterValue(self.threadMemory,register1)
            }
        else if mode == .indirect
            {
            let pointer = wordAsPointer(Word(immediate) + threadRegisterWordValue(self.threadMemory,register1))
            let value = wordAtIndexAtPointer(0,pointer) + 1
            setWordAtIndexAtPointer(value,0,pointer)
            }
        }
    
    @inline(__always)
    private func DEC(_ instruction:VMInstruction) throws
        {
        let mode = instruction.mode
        let register1 = instruction.register1.rawValue
        let immediate = ArgonWord(instruction.immediate)
        if mode == .register
            {
            decrementThreadRegisterValue(self.threadMemory,register1)
            }
        else if mode == .indirect
            {
            let pointer = wordAsPointer(Word(immediate) + threadRegisterWordValue(self.threadMemory,register1))
            let value = wordAtIndexAtPointer(0,pointer) - 1
            setWordAtIndexAtPointer(value,0,pointer)
            }
        }
    
    @inline(__always)
    private func BR(_ instruction:VMInstruction) throws
        {
        let immediate = Int32(instruction.immediate)
        if self.IP + immediate >= Int32(self.instructionCount)
            {
            throw(VirtualMachineFault.invalidAddress)
            }
        self.IP += immediate
        }
    
    @inline(__always)
    private func PUSH(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let immediate = instruction.immediate
        let mode = instruction.mode
        switch(mode)
            {
            case .register:
                pushWord(self.threadMemory,threadRegisterWordValue(self.threadMemory,register1))
            case .indirect:
                let address = Int(threadRegisterWordValue(self.threadMemory,register1)) + immediate
                pushWord(self.threadMemory,wordAtIndexAtPointer(0,wordAsPointer(Word(address))))
            case .immediate:
                pushWord(self.threadMemory,ArgonWord(immediate))
            case .address:
                pushWord(self.threadMemory,instruction.addressWord)
            default:
                throw(VirtualMachineSignal.invalidInstruction)
            }
        }
    
    @inline(__always)
    private func POP(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let mode = instruction.mode
        if mode == .register
            {
            setThreadRegisterWordValue(self.threadMemory,register1,Word(popWord(self.threadMemory)))
            }
        else if mode == .indirect
            {
            let immediate = ArgonWord(instruction.immediate)
            let pointer = wordAsPointer(Word(immediate) + threadRegisterWordValue(self.threadMemory,register1))
            setWordAtIndexAtPointer(popWord(self.threadMemory), 0, pointer)
            }
        else
            {
            throw(VirtualMachineSignal.invalidInstruction)
            }
        }
    }
