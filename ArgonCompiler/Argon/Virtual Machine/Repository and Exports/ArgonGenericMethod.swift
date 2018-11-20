//
//  ArgonGenericMethod.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class GenericMethodNode
    {
    private enum CodingKeys:String,CodingKey
        {
        case isPrimitive
        case kindHolder
        }
    
    public static let kKindParent = ArgonWord(0) << ArgonWord(63)
    public static let kKindChild = ArgonWord(1) << ArgonWord(63)
    public static let kKindShift = ArgonWord(63)
    
    public var kindHolder:KindHolder
    public var isPrimitive = false
    
    public var count:Int
        {
        return(0)
        }
    
    public var isChild:Bool
        {
        return(false)
        }
    
    init()
        {
        kindHolder = KindHolder(pointer:nil)
        }
    
    init(kindHolder:KindHolder)
        {
        self.kindHolder = kindHolder
        }
    
    public func addNodes(kinds:[KindHolder],method newMethod:ArgonMethod)
        {
        }
    
    public func print()
        {
        }
    
    public func select(from: [TraitsPointerWrapper]) -> Pointer?
        {
        fatalError("Should not be called")
        }
    
    public func write(into: Pointer,index:inout Int32)
        {
        fatalError("Should not be called")
        }
    }

public struct KindHolder
    {
    var traits:ArgonTraits?
    var traitsPointer:Pointer?
    
    init()
        {
        }
    
    init(traits:ArgonTraits? = nil)
        {
        self.traits = traits
        }
    
    init(pointer:Pointer?)
        {
        self.traitsPointer = pointer
        }
    }

public class GenericMethodParentNode:GenericMethodNode
    {
    public static let kMarkBottomMask = ArgonWord(255) << ArgonWord(56)
    
    public class func read(from:Pointer,index:inout Int32) throws -> GenericMethodParentNode
        {
        let node = GenericMethodParentNode(kindHolder: KindHolder())
        try node.read(from: from,index: &index)
        return(node)
        }
    
    public var children:[GenericMethodNode] = []
    
    public override var count:Int
        {
        var childCount = 0
        for child in children
            {
            childCount += child.count
            }
        return(1+childCount)
        }
    
    override init(kindHolder:KindHolder)
        {
        super.init(kindHolder:kindHolder)
        }
    
    override init()
        {
        super.init()
        }
    
    public override func select(from: [TraitsPointerWrapper]) -> Pointer?
        {
        let traits = from[0]
        for child in children
            {
            if traits.inherits(from: TraitsPointerWrapper(child.kindHolder.traitsPointer!))
                {
                return(child.select(from: from))
                }
            }
        return(nil)
        }
    
    public func read(from pointer:Pointer,index: inout Int32) throws
        {
        let newPointer = pointerAtIndexAtPointer(index,pointer)
        index += 1
        if isMarkedAsParent(newPointer)
            {
            let countWord = wordAtIndexAtPointer(index,pointer)
            index += 1
            if !isMarkedAsCount(countWord)
                {
                throw(VirtualMachineFault.encodedCountExpected)
                }
            let count = clearWordNodeMarks(countWord)
            let traitsPointer = untaggedPointer(clearPointerNodeMarks(newPointer))
            self.kindHolder = KindHolder(pointer: traitsPointer)
            for _ in 0..<count
                {
                if isMarkedAsParent(pointerAtIndexAtPointer(index,pointer))
                    {
                    let newNode = GenericMethodParentNode()
                    try newNode.read(from: pointer,index: &index)
                    self.children.append(newNode)
                    }
                else
                    {
                    let newNode = GenericMethodChildNode()
                    try newNode.read(from: pointer,index: &index)
                    self.children.append(newNode)
                    }
                }
            }
        }
    
    public override func write(into pointer: Pointer,index:inout Int32)
        {
//        Swift.print("Parent write \(kindHolder.traits?.name)")
        let nextPointer = markPointerAsParentNode(kindHolder.traitsPointer)
//        Swift.print("WRITE POINTER AS PARENT\(MachinePointer.bitString(of: nextPointer))")
        setUntaggedPointerAtIndexAtPointer(nextPointer,index,pointer)
        index += 1
        let word = markWordAsNodeCount(Word(children.count))
//        Swift.print("WRITE COUNT \(MachinePointer.bitString(of: word)) (\(children.count)) ")
        setWordAtIndexAtPointer(word,index,pointer)
        index += 1
        for child in children
            {
            child.write(into: pointer, index: &index)
            }
        }
    
    public func child(for traits:ArgonTraits) -> GenericMethodNode?
        {
        for child in children
            {
            if child.kindHolder.traits! == traits
                {
                return(child)
                }
            }
        return(nil)
        }

    public override func print()
        {
        Swift.print(kindHolder.traits!.name)
        for child in children
            {
            child.print()
            }
        }

    public override func addNodes(kinds:[KindHolder],method newMethod:ArgonMethod)
        {
        guard !kinds.isEmpty else
            {
            return
            }
//        Swift.print("kinds.count = \(kinds.count)")
//        Swift.print("kinds[0].traits = \(kinds[0].traits!.name)")
        for child in children
            {
            if child.kindHolder.traits! == kinds[0].traits
                {
//                    Swift.print("Found child with traits \(child.kindHolder.traits!.name)")
//                    Swift.print("Adding to this child")
                child.addNodes(kinds: Array(kinds.dropFirst()),method: newMethod)
                return
                }
            }
        if kinds.count == 1
            {
//            Swift.print("Adding CHILD Node with traits \(kinds[0].traits!.name)")
            let newNode = GenericMethodChildNode(kindHolder: kinds[0],method:newMethod)
            children.append(newNode)
            children.sort(by: {$0.kindHolder.traits!.inherits(from: $1.kindHolder.traits!)})
            return
            }
        else
            {
//            Swift.print("Adding PARENT Node with traits \(kinds[0].traits!.name)")
            let newNode = GenericMethodParentNode(kindHolder: kinds[0])
            children.append(newNode)
            children.sort(by: {$0.kindHolder.traits!.inherits(from: $1.kindHolder.traits!)})
            let kindString = "(" + (kinds.map{$0.traits!.name}.joined(separator:",")) + ")"
//            Swift.print("Adding children to this node - kinds = \(kindString)")
            newNode.addNodes(kinds: Array(kinds.dropFirst()),method: newMethod)
            }
        }
    }

public class GenericMethodChildNode:GenericMethodNode
    {
    private enum CodingKeys:String,CodingKey
        {
        case methodPointer
        }
    
    private var method:ArgonMethod?
    public var methodPointer:Pointer?
    
    public override var isChild:Bool
        {
        return(true)
        }
    
    public override var count:Int
        {
        return(1)
        }
    
    override init(kindHolder:KindHolder)
        {
        super.init(kindHolder:kindHolder)
        }
    
    override init()
        {
        super.init()
        }
    
    init(kindHolder:KindHolder,method:ArgonMethod)
        {
        self.method = method
        super.init(kindHolder:kindHolder)
        }
    
    init(kindHolder:KindHolder,method:Pointer)
        {
        self.methodPointer = method
        super.init(kindHolder:kindHolder)
        }
    
    public override func select(from: [TraitsPointerWrapper]) -> Pointer?
        {
        let traits = from[0]
        if traits.inherits(from: TraitsPointerWrapper(self.kindHolder.traitsPointer!))
            {
            return(methodPointer)
            }
        return(nil)
        }
    
    public func read(from pointer:Pointer,index: inout Int32) throws
        {
        let newPointer = pointerAtIndexAtPointer(index,pointer)
        index += 1
        let childPointer = untaggedPointer(clearPointerNodeMarks(newPointer))
        methodPointer = untaggedPointer(pointerAtIndexAtPointer(index,pointer))
        self.kindHolder = KindHolder(pointer: childPointer)
        index += 1
        }
    
    public override func print()
        {
//        Swift.print(kindHolder.traits!.name)
//        Swift.print("Method")
        }
    
    public override func write(into pointer: Pointer,index:inout Int32)
        {
//        Swift.print("Child.write \(kindHolder.traits!.name)")
        let childPointer = markPointerAsChildNode(kindHolder.traitsPointer!)
//        Swift.print("Write \(MachinePointer.bitString(of: childPointer)) Child(\(kindHolder.traits!.name))")
        setUntaggedPointerAtIndexAtPointer(childPointer,index,pointer)
        index += 1
//        Swift.print("Write Method(\(method!.pointer))")
        setUntaggedPointerAtIndexAtPointer(method!.pointer,index,pointer)
        index += 1
        }
    }
    
public class ArgonGenericMethod:ArgonModulePart
    {
    public var kind: ArgonModuleItemKind = .genericMethod
    public var instances:[ArgonMethod] = []
    public var returnTraits:ArgonTraits
    public var parameterCount:Int = 0
    public var selectionTreeRoot:GenericMethodParentNode = GenericMethodParentNode(kindHolder:KindHolder())
    public var allowsAnyArity = false
    public var directives:ArgonMethodDirective = []
    
    override init(fullName:String)
        {
        returnTraits = ArgonRelocationTable.shared.traits(at:"Argon::Void")!
        super.init(fullName: fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(kind.rawValue,forKey:"kind")
        aCoder.encode(instances,forKey:"instances")
        aCoder.encode(returnTraits,forKey:"returnTraits")
        aCoder.encode(parameterCount,forKey:"parameterCount")
        aCoder.encode(allowsAnyArity,forKey:"allowsAnyArity")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        kind = ArgonModuleItemKind(rawValue: aDecoder.decodeInteger(forKey: "kind"))!
        instances = aDecoder.decodeObject(forKey: "instances") as! [ArgonMethod]
        returnTraits = aDecoder.decodeObject(forKey: "returnTraits") as! ArgonTraits
        parameterCount = aDecoder.decodeInteger(forKey: "parameterCount")
        allowsAnyArity = aDecoder.decodeBool(forKey: "allowsAnyArity")
        super.init(coder:aDecoder)
        }
    
    public func updateParameters(from:Memory) throws
        {
        for instance in instances
            {
            try instance.updateParameters(from:from)
            }
        }
    
    fileprivate func kindHolders(for newMethod:ArgonMethod) -> [KindHolder]
        {
        var holders:[KindHolder] = []
        for traits in newMethod.parameters.map({$0.traits})
            {
            var holder = KindHolder(traits: traits)
            holder.traitsPointer = traits.pointer
            holders.append(holder)
            }
        return(holders)
        }
    
    private func addToMethodSelection(for instance:ArgonMethod)
        {
        let kinds = self.kindHolders(for: instance)
        if kinds.isEmpty
            {
            return
            }
        selectionTreeRoot.addNodes(kinds:kinds,method:instance)
        }
    
    public func add(instance:ArgonMethod)
        {
        if instances.count == 0
            {
            self.returnTraits = instance.returnType
            }
        instance.moduleName = ArgonName(self.fullName).first
        instances.append(instance)
        }
    
    public func buildDispatchTree() throws
        {
        for instance in instances
            {
            self.addToMethodSelection(for:instance)
            }
        }
    }
