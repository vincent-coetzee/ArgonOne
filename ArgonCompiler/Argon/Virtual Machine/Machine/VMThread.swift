//
//  VMThread.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

fileprivate enum RootContextItem
    {
    case register(Int,Int)
    case stack(Int,Int)
    }

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
    
    public static let kRegisterNone = 0
    public static let kRegisterBP = 1
    public static let kRegisterSP = 2
    public static let kRegisterIP = 3
    public static let kRegisterST = 4
    public static let kRegisterLP = 5
    
    public var codeBlockInstructionPointer:Pointer
    public private(set) var memory:Memory
    public private(set) var dataSegment:Pointer
    public private(set) var instructionCount:Int
    public private(set) var vm:VirtualMachine
    public private(set) var key:Int
    public private(set) var codeBlockPointer:CodeBlockPointerWrapper
    public private(set) var codeBlockInstructionCount:Int = 0
    public var pthread:pthread_t?
    private var registers:[Word] = Array(repeating: 0, count: 38)
    private var localStore = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
    private var LP:UnsafeMutableRawPointer = wordAsPointer(0)
    private var SP:UnsafeMutableRawPointer = wordAsPointer(0)
    public var IP:Int32 = 0
    public var conditions:ArgonWord = 0
    private var rootContextItems:[RootContextItem] = []
    
    private var isInSimulator = true
    
    init(vm:VirtualMachine,codeBlock:Pointer,IP:Int,capacity:ArgonWord)
        {
        self.codeBlockPointer = CodeBlockPointerWrapper(codeBlock)
        self.codeBlockInstructionPointer = codeBlockPointer.instructionPointer
        self.codeBlockInstructionCount = codeBlockPointer.instructionCount
        self.instructionCount = codeBlockPointer.instructionCount
        self.localStore = UnsafeMutableRawPointer.allocate(byteCount: Int(capacity), alignment: Int(ArgonWordSize))
        self.registers[MachineRegister.ST.rawValue] = Word(UInt(bitPattern: self.localStore.advanced(by: Int(capacity - ArgonWordSize))))
        self.registers[MachineRegister.SP.rawValue] = self.registers[MachineRegister.ST.rawValue]
        self.SP = wordAsPointer(self.registers[MachineRegister.ST.rawValue])
        self.LP = localStore
        self.memory = vm.memory
        self.dataSegment = vm.memory.dataSegment
        self.vm = vm
        self.key = Argon.nextCounter
        }
    
    public func registerValue(at register:MachineRegister) -> Word
        {
        return(registers[register.rawValue])
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
    
    public func addRootContentsToRootArray(threadIndex:Int,rootArray:Pointer)
        {
        rootContextItems = []
        for register in 1..<Argon.kNumberOfGeneralPurposeRegisters + Argon.kNumberOfReservedRegisters + 1
            {
            let word = self.registers[register]
            if isTaggedWord(word)
                {
                let index = addRootToRootArray(Memory.kSourceThreadRegister,threadIndex,register,wordAsPointer(word),rootArray)
                rootContextItems.append(RootContextItem.register(register,index))
                }
            }
        var pointer = wordAsPointer(self.registers[MachineRegister.ST.rawValue])
        let stackPointer = wordAsPointer(self.registers[MachineRegister.SP.rawValue])
        while pointer > stackPointer
            {
            let newPointer = pointerAtIndexAtPointer(0,pointer)
            if isTaggedPointer(newPointer)
                {
                let index = addRootToRootArray(Memory.kSourceThreadStack,threadIndex,pointer - stackPointer,newPointer,rootArray)
                rootContextItems.append(RootContextItem.stack(pointer-stackPointer,index))
                }
            pointer = pointer - Int(ArgonWordSize)
            }
        }
    
    public func updateContentsFrom(rootArray:Pointer)
        {
        for item in rootContextItems
            {
            switch(item)
                {
                case .register(let registerIndex,let rootIndex):
                    let holder = rootAtIndexInArray(rootArray, Int32(rootIndex))
                    self.registers[registerIndex] = pointerAsWord(holder.pointee.address)
                case .stack(let offset,let rootIndex):
                    let holder = rootAtIndexInArray(rootArray, Int32(rootIndex))
                    let pointer = self.SP - offset
                
                }
            }
        }
    
    private func dispatch(instruction:VMInstruction) throws
        {
        instruction.dump()
        switch(instruction.operation)
                {
                case .SIG:
                    try self.SIG(instruction)
                case .HAND:
                    try self.HAND(instruction)
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
    
    @inline(__always)
    private func MAKE(_ instruction:VMInstruction) throws
        {
        let parmCount = instruction.immediate
        var count:Word = 0
        if parmCount == 2
            {
            count = self.SP.load(fromByteOffset: 0, as: Word.self)
            self.SP += Int(ArgonWordSize)
            }
        let address = Pointer(word: self.SP.load(fromByteOffset: 0, as: Word.self))
        self.SP += Int(ArgonWordSize)
        if let vectorPointer = try self.memory.traits(atName: "Argon::Vector"),address == vectorPointer
            {
            self.registers[MachineRegister.R0.rawValue] = Word(pointer: try self.memory.allocate(vectorWithCapacity: Int(count)))
            }
        else
            {
            let traits = TraitsPointerWrapper(address)
            let totalSlots = traits.slotCount + Int(count)
            let instance = try self.memory.allocate(objectWithSlotCount: totalSlots, traits: address, ofType: Argon.kTypeInstance)
            self.registers[MachineRegister.R0.rawValue] = Word(pointer: instance)
            }
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
        }
    
    @inline(__always)
    private func SIG(_ instruction:VMInstruction) throws
        {
        let address = instruction.addressWord
        let targetSymbol = SymbolPointerWrapper(Pointer(word: address)).symbol
        let stackPointer = Pointer(word: self.registers[MachineRegister.SP.rawValue])
        let topOfStackPointer = Pointer(word: self.registers[MachineRegister.ST.rawValue])
        var pointer = stackPointer
        var stackDepth:Word = 0
        while pointer < topOfStackPointer
            {
            if isTaggedHandler(pointerAtIndexAtPointer(0,pointer))
                {
                let wrapper = HandlerPointerWrapper(pointer)
                if wrapper.symbol == targetSymbol
                    {
                    try self.invoke(handler: wrapper,stackDepth:Int(stackDepth))
                    return
                    }
                }
            pointer = pointer.advanced(by: Int(ArgonWordSize))
            stackDepth += ArgonWordSize
            }
        throw(RuntimeError.missingHandler(targetSymbol))
        }
    
    @inline(__always)
    private func unwindStack(to depth:Int) ->  [Word]
        {
        var words:[Word] = []
        var elementPointer = self.SP
        for _ in 0..<depth
            {
            words.append(wordAtIndexAtPointer(0,elementPointer))
            elementPointer += Int(ArgonWordSize)
            }
        return(words)
        }
    
    @inline(__always)
    private func invoke(handler:HandlerPointerWrapper,stackDepth:Int) throws
        {
        handler.signalingInstructionPointer = self.codeBlockInstructionPointer
        handler.signalingIP = self.IP;
        let words = self.unwindStack(to: stackDepth)
        handler.stackChunkCount = words.count
        try handler.setStackWords(words)
        self.codeBlockInstructionPointer = handler.handlerInstructionPointer
        self.IP = handler.handlerIP
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
        }
    
    @inline(__always)
    private func HAND(_ instruction:VMInstruction) throws
        {
        let pointer = Pointer(word: instruction.addressWord)
        let wrapper = HandlerPointerWrapper(pointer)
        let handler = taggedHandler(pointer)
        wrapper.handlerInstructionPointer = self.codeBlockInstructionPointer
        wrapper.handlerIP = self.IP + 8
        self.SP.storeBytes(of: ArgonWord(UInt(bitPattern: handler)), as: Word.self)
        self.SP -= Int(ArgonWordSize)
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
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
            parameters.append(self.SP.load(fromByteOffset: 0, as: Word.self))
            self.SP += Int(ArgonWordSize)
            }
        let traits = try self.traits(of: parameters,in: self)
        guard let methodPointer = genericPointer.selectionTreeRoot.select(from: traits) else
            {
            throw(VirtualMachineSignal.dispatchFailed)
            }
        let mainPointer = MethodPointerWrapper(methodPointer)
        let codeBlockPointer = mainPointer.codeBlock
        self.SP.storeBytes(of: Word(pointer: codeBlockInstructionPointer), as: Word.self)
        self.SP -= Int(ArgonWordSize)
        self.SP.storeBytes(of: Word(self.IP), as: Word.self)
        self.SP -= Int(ArgonWordSize)
        self.SP.storeBytes(of: Word(codeBlockInstructionCount), as: Word.self)
        self.SP -= Int(ArgonWordSize)
        self.codeBlockInstructionPointer = codeBlockPointer.instructionPointer
        self.codeBlockInstructionCount = codeBlockPointer.instructionCount
        self.IP = 0
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
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
        self.registers[register3] = self.registers[register1] | self.registers[register2]
        }
    
    @inline(__always)
    private func STORE(_ instruction:VMInstruction) throws
        {
        let mode = instruction.mode
        if mode == .address
            {
            let address = instruction.addressWord
            let value = self.registers[instruction.register1.rawValue]
            setWordAtIndexAtPointer(value,0,Pointer(bitPattern: UInt(address)))
            }
        else if mode == .immediate
            {
            let address = instruction.immediate
            let value = self.registers[instruction.register1.rawValue]
            setWordAtOffsetInDataSegment(value,Int32(address),dataSegment)
            }
        else if mode == .register
            {
            let address = addressOfNextFreeWordsOfSizeInDataSegment(Int32(MemoryLayout<Word>.size), dataSegment)
            setWordAtIndexAtPointer(self.registers[instruction.register1.rawValue],0,address)
            self.registers[instruction.register2.rawValue] = UInt64(UInt(bitPattern: address))
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
            self.registers[register1] = wordAtIndexAtPointer(0,wordAsPointer(address))
            }
        else if mode == .immediate
            {
            self.registers[register1] = wordAtIndexAtPointer(Int32(immediate),dataSegment)
            }
        }
    
    @inline(__always)
    private func OR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        self.registers[register3] = self.registers[register1] | self.registers[register2]
        }
    
    @inline(__always)
    private func XOR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        self.registers[register3] = self.registers[register1] ^ self.registers[register2]
        }
    
    @inline(__always)
    private func ADD(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        if instruction.mode == .immediate
            {
            self.registers[register2] = self.registers[register1] + Word(instruction.immediate)
            }
        else
            {
            self.registers[register3] = self.registers[register1] + self.registers[register2]
            }
        self.SP = wordAsPointer(self.registers[VMThread.kRegisterSP])
        }
    
    @inline(__always)
    private func SUB(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        if instruction.mode == .immediate
            {
            self.registers[register2] = self.registers[register1] - Word(instruction.immediate)
            }
        else
            {
             self.registers[register3] = self.registers[register1] - self.registers[register2]
            }
        self.SP = wordAsPointer(self.registers[VMThread.kRegisterSP])
        }
    
    @inline(__always)
    private func MUL(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        self.registers[register3] = self.registers[register1] * self.registers[register2]
        self.SP = wordAsPointer(self.registers[VMThread.kRegisterSP])
        }
    
    @inline(__always)
    private func DIV(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        self.registers[register3] = self.registers[register1] / self.registers[register2]
        self.SP = wordAsPointer(self.registers[VMThread.kRegisterSP])
        }
    
    @inline(__always)
    private func MOD(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let register3 = instruction.register3.rawValue
        self.registers[register3] = self.registers[register1] % self.registers[register2]
        self.SP = wordAsPointer(self.registers[VMThread.kRegisterSP])
        }
    
    @inline(__always)
    private func NOT(_ instruction:VMInstruction) throws
        {
        let register2 = instruction.register2.rawValue
        self.registers[register2] = ~self.registers[instruction.register1.rawValue]
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
            self.SP.storeBytes(of: Word(pointer: self.codeBlockInstructionPointer),as: Word.self)
            self.SP -= Int(ArgonWordSize)
            self.SP.storeBytes(of: Word(self.IP), as: Word.self)
            self.SP -= Int(ArgonWordSize)
            self.IP = Int32(self.IP) + immediate
            }
        else if aMode == .indirect
            {
            let address = Pointer(word: self.registers[register1] + Word(immediate))
            self.SP.storeBytes(of: Word(pointer: self.codeBlockInstructionPointer),as: Word.self)
            self.SP -= Int(ArgonWordSize)
            self.SP.storeBytes(of: Word(self.IP), as: Word.self)
            self.SP -= Int(ArgonWordSize)
            self.IP = Int32(ArgonWord(self.IP) + ArgonWord(wordAtIndexAtPointer(0,address)))
            }
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
        if isInSimulator
            {
            self.changed(aspect: "thread.codeLocation",with: (self.codeBlockInstructionPointer,self.codeBlockInstructionCount,self.IP),from: self)
            }
        }
    
    @inline(__always)
    private func RET(_ instruction:VMInstruction) throws
        {
        self.codeBlockInstructionCount = Int(self.SP.load(fromByteOffset: 0, as: Word.self))
        self.SP += Int(ArgonWordSize)
        self.IP = Int32(self.SP.load(fromByteOffset: 0, as: Word.self))
        self.SP += Int(ArgonWordSize)
        self.codeBlockInstructionPointer = Pointer(word: self.SP.load(fromByteOffset: 0, as: Word.self))
        self.SP += Int(ArgonWordSize)
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
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
        if self.registers[register1] == 1
            {
            self.IP += Int32(immediate)
            }
        }
    
    @inline(__always)
    private func BRF(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        if self.registers[register1] == 0
            {
            self.IP += Int32(instruction.immediate)
            }
        }
    
    @inline(__always)
    private func EQ(_ instruction:VMInstruction) throws
        {
        if self.registers[instruction.register1.rawValue] == self.registers[instruction.register2.rawValue]
            {
            self.registers[instruction.register3.rawValue] = 1
            }
        else
            {
            self.registers[instruction.register3.rawValue] = 0
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
        if self.registers[instruction.register1.rawValue] <= self.registers[instruction.register2.rawValue]
            {
            self.registers[instruction.register3.rawValue] = 1
            }
        else
            {
            self.registers[instruction.register3.rawValue] = 0
            }
        }
    
    @inline(__always)
    private func LT(_ instruction:VMInstruction) throws
        {
        if self.registers[instruction.register1.rawValue] < self.registers[instruction.register2.rawValue]
            {
            self.registers[instruction.register3.rawValue] = 1
            }
        else
            {
            self.registers[instruction.register3.rawValue] = 0
            }
        }
    
    @inline(__always)
    private func GT(_ instruction:VMInstruction) throws
        {
        if self.registers[instruction.register1.rawValue] > self.registers[instruction.register2.rawValue]
            {
            self.registers[instruction.register3.rawValue] = 1
            }
        else
            {
            self.registers[instruction.register3.rawValue] = 0
            }
        }
    
    @inline(__always)
    private func GTE(_ instruction:VMInstruction) throws
        {
        if self.registers[instruction.register1.rawValue] >= self.registers[instruction.register2.rawValue]
            {
            self.registers[instruction.register3.rawValue] = 1
            }
        else
            {
            self.registers[instruction.register3.rawValue] = 0
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
        self.registers[register1] = address
        }
    
    @inline(__always)
    private func MOVIR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let immediate = ArgonWord(instruction.immediate)
        self.registers[register1] = Word(immediate)
        }
    @inline(__always)
    private func MOVRR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        self.registers[register2] = self.registers[register1]
        self.SP = wordAsPointer(self.registers[VMThread.kRegisterSP])
        }
    
    @inline(__always)
    private func MOVNR(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let immediate = Int64(instruction.immediate)
        let value = Int(self.registers[register1]) + Int(immediate)
        self.registers[register2] = wordAtIndexAtPointer(0,wordAsPointer(Word(value)))
        }
    
    @inline(__always)
    private func MOVRN(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let register2 = instruction.register2.rawValue
        let immediate = instruction.immediate
        let value = Int(self.registers[register2]) + Int(immediate)
        setWordAtIndexAtPointer(self.registers[register1],0,wordAsPointer(Word(value)))
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
                let value = wordAsPointer(self.SP.load(fromByteOffset: 0, as: Word.self))
                self.SP += Int(ArgonWordSize)
                self.primitivePrint(value)
            }
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
        }
    
    private func primitivePrint(_ pointer:Pointer)
        {
        if isTaggedPointer(pointer)
            {
            let tag = tagOfPointer(pointer)
            switch(tag)
                {
                case Argon.kTagString:
                    print(StringPointerWrapper(pointer).string)
                case Argon.kTagSymbol:
                    print(StringPointerWrapper(pointer).string)
                case Argon.kTagTraits:
                    let wrapper = TraitsPointerWrapper(pointer)
                    let name = wrapper.name
                    let slotCount = wrapper.slotCount
                    print("Traits(\(name),\(slotCount) slots")
                default:
                    print("Pointer(\(pointerAsWord(untaggedPointer(pointer)))")
                }
            }
        else // If it is not tagged it must be an integer
            {
            print("\(pointerAsWord(pointer))")
            }
        }
    
    @inline(__always)
    private func INC(_ instruction:VMInstruction) throws
        {
        let mode = instruction.mode
        let register1 = instruction.register1.rawValue
        let immediate = ArgonWord(instruction.immediate)
        if mode == .register
            {
            self.registers[register1] += 1
            }
        else if mode == .indirect
            {
            let pointer = wordAsPointer(Word(immediate) + self.registers[register1])
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
            self.registers[register1] -= 1
            }
        else if mode == .indirect
            {
            let pointer = wordAsPointer(Word(immediate) + self.registers[register1])
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
        print("SP before PUSH = \(self.SP)")
        switch(mode)
            {
            case .register:
                self.SP.storeBytes(of: self.registers[register1], as: Word.self)
                self.SP -= Int(ArgonWordSize)
            case .indirect:
                let address = Word(Int(self.registers[register1]) + Int(immediate))
                self.SP.storeBytes(of: wordAtIndexAtPointer(0,Pointer(word:address)), as: Word.self)
                self.SP -= Int(ArgonWordSize)
            case .immediate:
                self.SP.storeBytes(of: ArgonWord(immediate), as: Word.self)
                self.SP -= Int(ArgonWordSize)
            case .address:
                self.SP.storeBytes(of: instruction.addressWord, as: Word.self)
                self.SP -= Int(ArgonWordSize)
            default:
                throw(VirtualMachineSignal.invalidInstruction)
            }
        print("SP after PUSH = \(self.SP)")
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
        }
    
    @inline(__always)
    private func POP(_ instruction:VMInstruction) throws
        {
        let register1 = instruction.register1.rawValue
        let mode = instruction.mode
        if mode == .register
            {
            let value = self.SP.load(fromByteOffset: 0, as: Word.self)
            self.SP += Int(ArgonWordSize)
            self.registers[register1] = value
            }
        else if mode == .indirect
            {
            let immediate = ArgonWord(instruction.immediate)
            let pointer = wordAsPointer(Word(immediate) + self.registers[register1])
            let value = self.SP.load(fromByteOffset: 0, as: Word.self)
            self.SP += Int(ArgonWordSize)
            setWordAtIndexAtPointer(value, 0, pointer)
            }
        else
            {
            throw(VirtualMachineSignal.invalidInstruction)
            }
        self.registers[VMThread.kRegisterSP] = pointerAsWord(self.SP)
        }
    }
