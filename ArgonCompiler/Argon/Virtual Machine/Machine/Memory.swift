//
//  ArgonInstanceBlock.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public typealias Pointer = UnsafeMutableRawPointer
public typealias Word = UInt64

extension Word
    {
    public init(pointer:Pointer)
        {
        self.init(UInt(bitPattern: pointer))
        }
    }

extension Pointer
    {
    public init(word:Word)
        {
        self.init(bitPattern: UInt(word))!
        }
    }

public class Memory
    {
    private static var memoryInstances:[Memory] = []
    
    public static func memory(of pointer:Pointer) -> Memory?
        {
        for instance in memoryInstances
            {
            if instance.ownsPointer(pointer)
                {
                return(instance)
                }
            }
        return(nil)
        }
    
    public static let kSourceThreadInvalid = -1
    public static let kSourceInvalid = -1
    public static let kSourceThreadStack = 1
    public static let kSourceData = 2
    public static let kSourceThreadRegister = 3
    public static let kSourceGlobal = 4
    
    private var fromSpace:UnsafeMutablePointer<Space>
    public private(set) var toSpace:UnsafeMutablePointer<Space>
    public private(set) var dataSegment = allocateDataSegmentWithCapacity(10)
    private var globalReferences:[String:GlobalMemoryReference] = [:]
    private var memoryMutexPointer = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    private var dataSegmentOffset = 8
    
    public var spaceUsed:Int
        {
        return(Int(spaceUsedInSpace(toSpace)))
        }
    
    init(capacity:Int,dataCapacity:Int) throws
        {
        memoryMutexPointer.pointee = pthread_mutex_t()
        let attributesPointer = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        pthread_mutexattr_init(attributesPointer);
        pthread_mutexattr_settype(attributesPointer, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(memoryMutexPointer, attributesPointer)
        freeDataSegment(dataSegment)
        dataSegment = allocateDataSegmentWithCapacity(Int32(dataCapacity))
        fromSpace = allocateSpaceWithCapacity(Int32(capacity))
        toSpace = allocateSpaceWithCapacity(Int32(capacity))
        try initBaseMethods()
        try initBaseTraits()
        try initSymbolTree()
        Memory.memoryInstances.append(self)
        }
    
    deinit
        {
        memoryMutexPointer.deallocate()
        freeDataSegment(dataSegment)
        freeSpace(fromSpace)
        freeSpace(toSpace)
        }
    
    public func ownsPointer(_ pointer:Pointer) -> Bool
        {
        if pointerInSpace(pointer,fromSpace)
            {
            return(true)
            }
        if pointerInSpace(pointer,toSpace)
            {
            return(true)
            }
        return(false)
        }
    
    public func addRoot(name:String,pointer:Pointer)
        {
        let index = globalReferences.count
        let address = addressOfNextFreeWordsOfSizeInDataSegment(Int32(ArgonWordSize),dataSegment)
        setPointerAtIndexAtPointer(pointer,0,address)
        let reference = GlobalMemoryReference(name: name, dataSegmentAddress: address, index: index, address: pointer)
        globalReferences[name] = reference
        }
    
    private func updateGlobalsFrom(rootArray:Pointer)
        {
        for global in globalReferences.values
            {
            let holder = rootAtIndexInArray(rootArray,Int32(global.rootArrayIndex))
            global.address = holder.pointee.address
            }
        }
    
    private func addGlobalsToRootArray(rootArray:Pointer)
        {
        for global in globalReferences.values
            {
            global.rootArrayIndex = addRootToRootArray(Memory.kSourceGlobal,Memory.kSourceThreadInvalid,global.index,global.address,rootArray)
            }
        }
    public func copyToSpace(size: Int, to pointer:UnsafeMutableRawPointer)
        {
        copySpaceOfSizeToPointer(toSpace,Int32(size),pointer)
        }
    
    public func copyFromSpace(size: Int, to pointer:UnsafeMutableRawPointer)
        {
        copySpaceOfSizeToPointer(fromSpace,Int32(size),pointer)
        }
    
    public func allocate(objectWithSlotCount slotCount:Int,traits:Pointer,ofType type:Int) throws -> UnsafeMutableRawPointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        guard let address = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(type)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        setPointerAtIndexAtPointer(traits,1,address)
        pthread_mutex_unlock(memoryMutexPointer)
        return(taggedInstancePointer(address))
        }
    
    public func allocate(traitsNamed name:String,slots:[MemorySlotLayout],parents:[Pointer],lookupTraits:Bool = false) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let slotCount = TraitsPointerWrapper.kFixedSlotCount + parents.count + slots.count*3 + 1
        guard let address = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeTraits)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        setPointerAtIndexAtPointer(try self.allocate(string: name), Int32(TraitsPointerWrapper.kNameIndex), address)
        setWordAtIndexAtPointer(Word(parents.count), Int32(TraitsPointerWrapper.kParentCountIndex), address)
        setWordAtIndexAtPointer(Word(slots.count), Int32(TraitsPointerWrapper.kSlotCountIndex), address)
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName: "Argon::Traits")!, Int32(TraitsPointerWrapper.kTraitsIndex), address)
            }
        var index = Int32(TraitsPointerWrapper.kFixedSlotCount)
        for parent in parents
            {
            setPointerAtIndexAtPointer(parent, index, address)
            index += 1
            }
        for slot in slots
            {
            let namePointer = try self.allocate(string: slot.name)
            setPointerAtIndexAtPointer(namePointer, index, address)
            index += 1
            setPointerAtIndexAtPointer(slot.traits,index,address) // traits of slot should go here
            index += 1
            setWordAtIndexAtPointer(Word(slot.offset),index,address) // traits of slot should go here
            index += 1
            }
        return(taggedTraitsPointer(address))
        }
    
    public func allocate(closureWithVariableCount count:Int) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let slotCount = ClosurePointerWrapper.kFixedSlotCount
        guard let pointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeString)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        setPointerAtIndexAtPointer(try self.traits(atName:"Argon::Closure")!,1,pointer)
        setWordAtIndexAtPointer(Word(count),ClosurePointerWrapper.kVariableCountIndex, pointer)
        setWordAtIndexAtPointer(0, ClosurePointerWrapper.kMonitorIndex, pointer)
        setWordAtIndexAtPointer(0, ClosurePointerWrapper.kCodeBlockIndex, pointer)
        return(taggedClosurePointer(pointer))
        }
    
    public func allocate(handlerForSymbol symbolPointer:Pointer) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let slotCount = HandlerPointerWrapper.kFixedSlotCount
        guard let pointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeHandler)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        setPointerAtIndexAtPointer(try self.traits(atName:"Argon::Handler")!,HandlerPointerWrapper.kTraitsIndex,pointer)
        setWordAtIndexAtPointer(0, HandlerPointerWrapper.kMonitorIndex, pointer)
        setPointerAtIndexAtPointer(symbolPointer, HandlerPointerWrapper.kTypeSymbolIndex, pointer)
        return(taggedHandlerPointer(pointer))
        }
    
    public func allocate(string:String,lookupTraits:Bool = false) throws -> UnsafeMutableRawPointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let wordsNeeded = ((string.count / 2) + 1) * 3 / 2
        let capacity = wordsNeeded / 2
        let slotCount = 5 + wordsNeeded
        guard let pointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeString)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::String")!,Int32(StringPointerWrapper.kTraitsIndex),pointer)
            }
        setWordAtIndexAtPointer(Word(capacity), Int32(StringPointerWrapper.kCapacityIndex), pointer)
        setWordAtIndexAtPointer(0, Int32(StringPointerWrapper.kSpareIndex), pointer)
        let stringPointer = StringPointerWrapper(pointer)
        stringPointer.string = string
        return(taggedStringPointer(pointer))
        }
    
    public func allocate(symbol:String,lookupTraits:Bool = false) throws -> UnsafeMutableRawPointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let wordsNeeded = ((symbol.count / 2) + 1) * 3 / 2
        let capacity = wordsNeeded / 2
        let slotCount = 5 + wordsNeeded
        guard let pointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeSymbol)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::Symbol")!,Int32(StringPointerWrapper.kTraitsIndex),pointer)
            }
        setWordAtIndexAtPointer(Word(capacity), Int32(StringPointerWrapper.kCapacityIndex), pointer)
        setWordAtIndexAtPointer(0, Int32(StringPointerWrapper.kSpareIndex), pointer)
        let stringPointer = StringPointerWrapper(pointer)
        stringPointer.string = symbol
        return(taggedSymbolPointer(pointer))
        }
    
    public func allocate(genericMethodNamed name:String,parameterCount:Int,selectionTreeRoot root:GenericMethodParentNode) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let slotCount = GenericMethodPointerWrapper.kFixedSlotCount + parameterCount + root.count * 2
        guard let pointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeGenericMethod)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        setPointerAtIndexAtPointer(try self.traits(atName:"Argon::GenericMethod")!,Int32(GenericMethodPointerWrapper.kTraitsIndex),pointer)
        setPointerAtIndexAtPointer(try allocate(string: name),GenericMethodPointerWrapper.kNameIndex,pointer)
        setWordAtIndexAtPointer(Word(parameterCount),GenericMethodPointerWrapper.kParameterSlotCountIndex,pointer)
        var index:Int32 = Int32(GenericMethodPointerWrapper.kTreeIndex)
        root.write(into: pointer,index: &index)
        return(taggedMethodPointer(pointer))
        }
    
    public func allocate(methodNamed:String,parameterCount:Int,lookupTraits:Bool = false) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let slotCount = MethodPointerWrapper.kFixedSlotCount
        guard let pointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeMethod)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        setPointerAtIndexAtPointer(try self.traits(atName:"Argon::Method")!,Int32(MethodPointerWrapper.kTraitsIndex),pointer)
        setPointerAtIndexAtPointer(try allocate(string: methodNamed),MethodPointerWrapper.kNameIndex,pointer)
        setWordAtIndexAtPointer(Word(parameterCount),MethodPointerWrapper.kParameterCountIndex,pointer)
        setWordAtIndexAtPointer(Word(0),MethodPointerWrapper.kInstructionCountIndex,pointer)
        setWordAtIndexAtPointer(Word(0),MethodPointerWrapper.kCodeBlockIndex,pointer)
        return(taggedMethodPointer(pointer))
        }
    
    public func allocate(codeBlock instructions:[VMInstruction]) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let slots = instructions.count + CodeBlockPointerWrapper.kFixedSlotCount
        let codeBlock = try allocate(objectWithSlotCount: slots, traits:try self.traits(atName:"Argon::CodeBlock")!, ofType: Argon.kTypeCodeBlock)
        setWordAtIndexAtPointer(Word(instructions.count),CodeBlockPointerWrapper.kInstructionCountIndex,codeBlock)
        var index:Int32 = CodeBlockPointerWrapper.kInstructionsIndex
        for instruction in instructions
            {
            let word = instruction.instructionWord
            setWordAtIndexAtPointer(word,index,codeBlock)
            index += 1
            if instruction.mode == .address
                {
                let address = instruction.addressWord
                setWordAtIndexAtPointer(address,index,codeBlock)
                index += 1
                }
            }
        return(taggedCodeBlockPointer(codeBlock))
        }
    
    public func allocate(associationVectorWithCapacity size:Int,flags:Int = 0,lookupTraits:Bool = false) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let maximumSize = size * 2
        let slotCount = maximumSize + AssociationVectorPointer.kFixedSlotCount
        guard let address = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeAssociationVector)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::AssociationVector")!, Int32(VectorPointer.kTraitsIndex), address)
            }
        setWordAtIndexAtPointer(0, Int32(VectorPointer.kCountIndex), address)
        setWordAtIndexAtPointer(Word(maximumSize), Int32(VectorPointer.kCapacityIndex), address)
        return(taggedVectorPointer(address))
        }
    
    public func allocate(mapWithFlags flags:Int = 0,lookupTraits:Bool = false) throws -> UnsafeMutableRawPointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let maximumSize = Argon.kHashMapPrime + 1
        let slotCount = maximumSize + MapPointerWrapper.kFixedSlotCount
        guard let address = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeAssociationVector)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::Map")!, Int32(VectorPointer.kTraitsIndex), address)
            }
        setWordAtIndexAtPointer(0, Int32(VectorPointer.kCountIndex), address)
        setWordAtIndexAtPointer(Word(maximumSize), Int32(VectorPointer.kCapacityIndex), address)
        return(taggedMapPointer(address))
        }
    
    public func allocate(allocationBlockWithSlotCount slotCount:Int,lookupTraits:Bool = true) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let totalSlots = Int32(slotCount) + AllocationBlockPointerWrapper.kFixedSlotCount
        guard let address = SharedMemory.allocateInstance(toSpace,totalSlots,Int32(Argon.kTypeAllocationBlock)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::AllocationBlock")!, Int32(AllocationBlockPointerWrapper.kTraitsIndex), address)
            }
        setWordAtIndexAtPointer(Word(slotCount), Int32(AllocationBlockPointerWrapper.kCapacityIndex), address)
        return(taggedBlockPointer(address))
        }
    
    public func allocate(vectorWithCapacity size:Int,flags:Int = 0,lookupTraits:Bool = false) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let maximumSize = size * 3 / 2
        let slotCount = maximumSize + VectorPointer.kFixedSlotCount
        guard let address = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeVector)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::Vector")!, Int32(VectorPointer.kTraitsIndex), address)
            }
        setWordAtIndexAtPointer(0, Int32(VectorPointer.kCountIndex), address)
        setWordAtIndexAtPointer(Word(maximumSize), Int32(VectorPointer.kCapacityIndex), address)
        let allocationBlock = try self.allocate(allocationBlockWithSlotCount:maximumSize,lookupTraits:lookupTraits)
        setPointerAtIndexAtPointer(allocationBlock, Int32(VectorPointer.kBlockPointerIndex), address)
        return(taggedVectorPointer(address))
        }
    
    public func allocate(treeWithCapacity capacity:Int,lookupTraits:Bool = false) throws -> Pointer
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let maximumSize = (capacity * 3 / 2)*3
        let slotCount = maximumSize + SymbolTreePointerWrapper.kFixedSlotCount
        guard let treePointer = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(Argon.kTypeSymbolTree)) else
            {
            throw(VirtualMachineSignal.outOfMemory)
            }
        if lookupTraits
            {
            setPointerAtIndexAtPointer(try self.traits(atName:"Argon::SymbolTree")!, Int32(VectorPointer.kTraitsIndex), treePointer)
            }
        setWordAtIndexAtPointer(0, Int32(SymbolTreePointerWrapper.kNodeCountIndex), treePointer)
        setWordAtIndexAtPointer(Word(maximumSize), Int32(SymbolTreePointerWrapper.kNodeCapacityIndex), treePointer)
        setWordAtIndexAtPointer(Word(SymbolTreePointerWrapper.kFixedSlotCount + 1), Int32(SymbolTreePointerWrapper.kNextNodeIndexIndex), treePointer)
        return(taggedInstancePointer(treePointer))
        }
    
    private func initBaseMethods() throws
        {
        let pointer = try self.allocate(mapWithFlags: 0)
        self.addRoot(name: "methodMap",pointer: pointer)
        }
    
    private func initSymbolTree() throws
        {
        let treePointer = try self.allocate(treeWithCapacity: 5000,lookupTraits:true)
        self.addRoot(name: "symbolTree",pointer: treePointer)
        }
    
    private func initBaseTraits() throws
        {
        let pointer = try self.allocate(mapWithFlags: 0)
        self.addRoot(name: "traits", pointer: pointer)
        let traitsMap = MapPointerWrapper(pointer,objectMemory:self)
        let behaviour = try self.allocate(traitsNamed: "Argon::Behaviour", slots:[],parents:Array<Pointer>())
        try traitsMap.setPointer(behaviour,forKey:"Argon::Behaviour")
        let handler = try self.allocate(traitsNamed: "Argon::Handler", slots:[],parents:[behaviour])
        try traitsMap.setPointer(handler,forKey:"Argon::Handler")
        let traits = try self.allocate(traitsNamed: "Argon::Traits", slots:[],parents:Array<Pointer>())
        try traitsMap.setPointer(traits,forKey:"Argon::Traits")
        let number = try self.allocate(traitsNamed: "Argon::Number",slots:[], parents: [behaviour])
        try traitsMap.setPointer(number,forKey:"Argon::Number")
        let integer = try self.allocate(traitsNamed: "Argon::Integer", slots:[],parents: [number])
        try traitsMap.setPointer(integer,forKey:"Argon::Integer")
        let method = try self.allocate(traitsNamed: "Argon::Method", slots:[],parents:[behaviour])
        try traitsMap.setPointer(method,forKey:"Argon::Method")
        let closure = try self.allocate(traitsNamed: "Argon::Closure", slots:[],parents:[behaviour])
        try traitsMap.setPointer(closure,forKey:"Argon::Closure")
        let genericMethod = try self.allocate(traitsNamed: "Argon::GenericMethod", slots:[],parents:[method])
        try traitsMap.setPointer(genericMethod,forKey:"Argon::GenericMethod")
        let comparable = try self.allocate(traitsNamed: "Argon::Comparable", slots:[],parents: [behaviour])
        try traitsMap.setPointer(comparable,forKey:"Argon::Comparable")
        let equatable = try self.allocate(traitsNamed: "Argon::Equatable",slots:[], parents: [behaviour])
        try traitsMap.setPointer(equatable,forKey:"Argon::Equatable")
        let collection = try self.allocate(traitsNamed: "Argon::Collection",slots:[], parents: [behaviour])
        try traitsMap.setPointer(collection,forKey:"Argon::Collection")
        let block = try self.allocate(traitsNamed: "Argon::AllocationBlock",slots:[], parents: [collection])
        try traitsMap.setPointer(block,forKey:"Argon::AllocationBlock")
        let symbolTree = try self.allocate(traitsNamed: "Argon::SymbolTree",slots:[], parents: [collection])
        try traitsMap.setPointer(symbolTree,forKey:"Argon::SymbolTree")
        let vector = try self.allocate(traitsNamed: "Argon::Vector",slots:[MemorySlotLayout("header",0,integer),MemorySlotLayout("traits",Int(ArgonWordSize),traits),MemorySlotLayout("monitor",2*Int(ArgonWordSize),integer),MemorySlotLayout("count",3*Int(ArgonWordSize),integer),MemorySlotLayout("capacity",4*Int(ArgonWordSize),integer),MemorySlotLayout("block",5*Int(ArgonWordSize),block),MemorySlotLayout("spare",6*Int(ArgonWordSize),integer)], parents: [collection])
        try traitsMap.setPointer(vector,forKey:"Argon::Vector")
        let codeBlock = try self.allocate(traitsNamed: "Argon::CodeBlock",slots:[], parents: [vector])
        try traitsMap.setPointer(codeBlock,forKey:"Argon::CodeBlock")
        let associationVector = try self.allocate(traitsNamed: "Argon::AssociationVector",slots:[], parents: [vector])
        try traitsMap.setPointer(associationVector,forKey:"Argon::AssociationVector")
        let string = try self.allocate(traitsNamed: "Argon::String",slots:[], parents: [vector])
        try traitsMap.setPointer(string,forKey:"Argon::String")
        
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Date", slots:[],parents: [number]),forKey:"Argon::Date")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Boolean",slots:[], parents: [number]),forKey:"Argon::Boolean")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Symbol", slots:[],parents: [string]),forKey:"Argon::Symbol")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Float", slots:[],parents: [number]),forKey:"Argon::Float")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Map", slots:[],parents: [collection]),forKey:"Argon::Map")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Tuple",slots:[], parents: [collection]),forKey:"Argon::Tuple")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::Hashable",slots:[], parents: [comparable,equatable]),forKey:"Argon::Hashable")
        try traitsMap.setPointer(try self.allocate(traitsNamed: "Argon::BitSet",slots:[], parents: [collection]),forKey:"Argon::BitSet")
        let dataBytes = dataSegment.advanced(by: 16)
        let dataPointer = pointerAtIndexAtPointer(0,dataBytes)
        setPointerAtIndexAtPointer(pointer,Argon.kDataSegmentIndexTraitsMap,dataPointer)
        traitsMap.dump()
        let aPointer = try traitsMap.pointer(forKey: "Argon::Closure")
        print(aPointer ?? "")
        try testMaps()
        }
    
    public func traits(atName name:String) throws -> Pointer?
        {
        return(try MapPointerWrapper(globalReferences["traitsMap"]!.address,objectMemory: self).pointer(forKey: name))
        }
    
    public func setTraits(_ traits:Pointer,atName name:String) throws
        {
        try MapPointerWrapper(globalReferences["traitsMap"]!.address,objectMemory: self).setPointer(traits,forKey: name)
        }
    
    public func method(atName name:String) throws -> Pointer?
        {
        return(try MapPointerWrapper(globalReferences["methodMap"]!.address,objectMemory: self).pointer(forKey: name))
        }
    
    public func setMethod(_ pointer:Pointer,atName name:String) throws
        {
        try MapPointerWrapper(globalReferences["methodMap"]!.address,objectMemory: self).setPointer(pointer,forKey: name)
        }
    
    public func symbol(atSymbol symbol:String) throws -> Pointer?
        {
        return(SymbolTreePointerWrapper(globalReferences["symbolTree"]!.address).find(symbol:symbol))
        }
    
    public func setSymbol(_ symbol:String) throws -> Pointer
        {
        return(try SymbolTreePointerWrapper(globalReferences["symbolTree"]!.address).add(symbol: symbol, memory: self))
        }
    
    public func collectGarbage(_ threads:[VMThread])
        {
        pthread_mutex_lock(memoryMutexPointer)
        defer
            {
            pthread_mutex_unlock(memoryMutexPointer)
            }
        let rootArray = allocateRootArray()
        self.addGlobalsToRootArray(rootArray:rootArray)
        var index = 0
        for thread in threads
            {
            thread.addRootContentsToRootArray(threadIndex:index,rootArray:rootArray)
            index += 1
            }
        addDataContentsToRootArray(self.dataSegment,rootArray)
        copyRootsFromTo(rootArray,fromSpace, toSpace)
        self.updateGlobalsFrom(rootArray:rootArray)
        for thread in threads
            {
//            thread.updateRootContentsFrom(rootArray:rootArray)
            }
        freeRootArray(rootArray)
        }
    
    func testMaps() throws
        {
        let associations = try self.allocate(associationVectorWithCapacity: 15)
        let pointer = AssociationVectorPointer(associations)
        var objects:[Pointer] = []
        for index in 0..<15
            {
            let object = try self.allocate(objectWithSlotCount: 3, traits: wordAsPointer(0),ofType: Argon.kTypeInstance)
            objects.append(object)
            pointer.append(key: object, value: Word(index * 10))
            }
        assert(pointer.count == 15)
        for index in 0..<15
            {
            let association = pointer.association(at: index)
            assert(untaggedPointer(association.key) == untaggedPointer(objects[index]))
            assert(pointerAsWord(untaggedPointer(association.value)) == (index*10))
            }
        let mapPointer = MapPointerWrapper(try self.allocate(mapWithFlags: 0), objectMemory: self)
        var keys:[String] = []
        var data:[String] = []
        for loop in 0..<250
            {
            let stringKey = "Key\(loop)"
            keys.append(stringKey)
            let stringData = "This is some data that will be associated with the key \(loop)\(loop)"
            data.append(stringData)
            try mapPointer.setPointer(try self.allocate(string: stringData), forKey: stringKey)
            }
        assert(mapPointer.count == 250)
        for loop in 0..<250
            {
            let oldValue = StringPointerWrapper(try mapPointer.pointer(forKey: keys[loop])!)
            assert(oldValue.string == data[loop])
            }
        }
    
    private func testStrings() throws
        {
        var strings:[String] = []
        var pointers:[UnsafeMutableRawPointer] = []
        for index in 0..<50
            {
            let baseString = "Base\(index)"
            var newString = baseString
            for _ in 0..<index
                {
                newString += baseString
                }
            strings.append(newString)
            pointers.append(try self.allocate(string: newString))
            }
        for index in 0..<pointers.count
            {
            let string = StringPointerWrapper(pointers[index])
            assert(string.string == strings[index])
            }
        }
    
    public func testAllocation()
        {
        do
            {
            try testStrings()
            try testMaps()
//            testStack()
            let rootArray = allocateRootArray()
            let testString = "The quick brown fox jumped over the lazy dog which was fast asleep on the couch in the lounge after a long night of raving."
            let string = try self.allocate(string:testString)
//            let stringIndex = addRootFromSourceToRootArray(string,Memory.kSourceGlobal,nil,1,rootArray)
//            print(stringIndex)
            let vector = try self.allocate(vectorWithCapacity: 150)
            let vectorPointer = VectorPointer(vector)
            for loop in 0..<125
                {
                let aString = "This is a string number \(loop)"
                try vectorPointer.append(try self.allocate(string: aString))
                }
//            let vectorIndex = addRootFromSourceToRootArray(vector,Memory.kSourceGlobal,nil,1,rootArray)
            for loop in 0..<125
                {
                let innerString = StringPointerWrapper(vectorPointer.pointerItem(at: loop))
                let innerStringValue = innerString.string
                assert(innerStringValue == "This is a string number \(loop)")
                }
            let newPointer = StringPointerWrapper(string)
            print(newPointer)
            for index in 0..<599
                {
                let slotCount = 1 + 5
                let pointer = SharedMemory.allocateInstance(toSpace,2,Int32(InstancePointerWrapper.kTypeVector))
                let object = SharedMemory.allocateInstance(toSpace,Int32(slotCount),Int32(InstancePointerWrapper.kTypeVector))
                setPointerAtIndexAtPointer(pointer,1,object)
//                addRootFromSourceToRootArray(object,Memory.kSourceGlobal,nil,Int32(index),rootArray)
                }
            let anotherString = try self.allocate(string: "This is another string to store in a register")
//            setPointerInRegister(registerSet,anotherString, 12)
            let yetAnotherString = try self.allocate(string: "This is yet another string to be daved in memory")
//            setPointerAtOffsetInDataSegment(yetAnotherString, 0, dataSegment)
            let thirdString = try self.allocate(string: "Another junk object but this time going to the stack")
//            pushPointer(toSpace,thirdString);
            var object = rootAtIndexInArray(rootArray,357).pointee.address
            setWordAtIndexAtPointer(987247,3,object)
            object = rootAtIndexInArray(rootArray,358).pointee.address
            setWordAtIndexAtPointer(2002,3,object)
            object = rootAtIndexInArray(rootArray,511).pointee.address
            setWordAtIndexAtPointer(14986,3,object)
            addDataContentsToRootArray(dataSegment, rootArray)
//            addRegisterContentsToRootArray(registerSet,rootArray)
//            addStackContentsToRootArray(toSpace, rootArray)
//            printStack()
//            var timer = Timer()
            let stackCount1 = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
//            let stackContents1 = SharedMemory.stackContents(toSpace,stackCount1)
//            print(stackContents1)
            copyRootsFromTo(rootArray,fromSpace, toSpace)
//            print("\(timer.stop()) ms for GC")
//            printStack()
            let stackCount2 = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
//            let stackContents2 = SharedMemory.stackContents(toSpace,stackCount2)
//            print(stackContents2)
//            timer = Timer()
            copyRootsFromTo(rootArray,fromSpace, toSpace)
//            print("\(timer.stop()) ms for GC")
//            timer = Timer()
            copyRootsFromTo(rootArray,fromSpace, toSpace)
//            print("\(timer.stop()) ms for GC")
//            updateRootSources(registerSet,toSpace, dataSegment, rootArray)
//            printStack()
//            let stackItem = popPointer(toSpace)
//            assert(StringPointer(stackItem).string == "Another junk object but this time going to the stack")
//            let string1 = pointerInRegister(registerSet,12)
//            let string1Pointer = StringPointer(string1)
//            let string1Result = string1Pointer.string
//            assert(string1Result == "This is another string to store in a register")
//            let string2 = pointerAtOffsetInDataSegment(0,dataSegment)
//            let string2Pointer = StringPointer(string2)
//            assert(string2Pointer.string == "This is yet another string to be daved in memory")
            object = rootAtIndexInArray(rootArray,357).pointee.address
            var word = wordAtIndexAtPointer(3, object)
            assert(word == 987247)
            object = rootAtIndexInArray(rootArray,358).pointee.address
            word = wordAtIndexAtPointer(3, object)
            assert(word == 2002)
            object = rootAtIndexInArray(rootArray,511).pointee.address
            word = wordAtIndexAtPointer(3, object)
            assert(word == 14986)
//            let endVector = VectorPointer(rootAtIndexInArray(rootArray,vectorIndex).pointee.address!)
//            for loop in 0..<125
//                {
//                let endStringPointer = StringPointerWrapper(endVector.pointerItem(at: loop))
//                assert(endStringPointer.string == "This is a string number \(loop)")
//                }
            }
        catch
            {
            print("\(error)")
            }
        }
    }
