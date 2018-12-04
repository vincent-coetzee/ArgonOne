//
//  ArgonTraitsNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public struct ArgonSlotLayoutNode
    {    
    public var name:String
    public var offsetInInstance:Int
    public var traits:ArgonTraitsNode
    
    init(name:String,offset:Int,traits:ArgonTraitsNode)
        {
        self.name = name
        self.offsetInInstance = offset
        self.traits = traits
        }
    }

public struct ArgonSlotList:Collection
    {
    fileprivate var _slots:[ArgonName:ArgonSlotNode] = [:]
    fileprivate var _slotArray:[ArgonSlotNode] = []
    
    public var count:Int
        {
        return(_slotArray.count)
        }
    
    public var slots:[ArgonSlotNode]
        {
        return(_slotArray)
        }

    public var startIndex:Int
        {
        return(_slotArray.startIndex)
        }
    
    public var endIndex:Int
        {
        return(_slotArray.endIndex)
        }
    
    init(slots newSlots:[ArgonSlotNode])
        {
        for slot in newSlots
            {
            self.addUniqueSlot(slot)
            }
        _slotArray.sort(by: {$0.name.string < $1.name.string})
        }
    
    init()
        {
        }
    
    public func index(after:Int) -> Int
        {
        return(_slotArray.index(after:after))
        }
    
    public subscript(_ index:Int) -> ArgonSlotNode
        {
        return(_slotArray[index])
        }
    
    private mutating func addUniqueSlot(_ slot:ArgonSlotNode)
        {
        if _slots[slot.name] == nil
            {
            _slots[slot.name] = slot
            _slotArray.append(slot)
            }
        }
    
    public subscript(_ name:ArgonName) -> ArgonSlotNode?
        {
        return(_slots[name])
        }
    
    public mutating func append(_ slot:ArgonSlotNode)
        {
        self.addUniqueSlot(slot)
        _slotArray.sort(by: {$0.name.string < $1.name.string})
        }
    
    public mutating func append(contentsOf list: ArgonSlotList)
        {
        for slot in list
            {
            self.addUniqueSlot(slot)
            }
        _slotArray.sort(by: {$0.name.string < $1.name.string})
        }
    }

public class ArgonTraitsNode:ArgonExpressionNode,ArgonParseScope,Comparable,ArgonType,ArgonExportableItem,ThreeAddress
    {
    
    public func isSame(as address:ThreeAddress) -> Bool
        {
        if type(of: address) == type(of: self)
            {
            return(address as! ArgonTraitsNode == self)
            }
        return(false)
        }
    public static func == (lhs: ArgonTraitsNode, rhs: ArgonTraitsNode) -> Bool
        {
        return(lhs.name == rhs.name)
        }
    
    public static func < (lhs: ArgonTraitsNode, rhs: ArgonTraitsNode) -> Bool
        {
        return(lhs.subTraits(of: rhs))
        }
    
    public var name:ArgonName = ArgonName("ERROR")
    private var slots = ArgonSlotList()
    public var typeTemplates:[ArgonTypeTemplateNode] = []
    public private(set) var slotLayouts:[ArgonName:ArgonSlotLayoutNode] = [:]
    public private(set) var instanceSlotCount:Int = 0
    public var containingScope:ArgonParseScope?
    public private(set) var methods:[ArgonName:ArgonTraitsMethodNode] = [:]
    public var parents:[ArgonTraitsNode] = []
    public var enclosingStackFrame:ArgonStackFrame?
    public var fullName:ArgonName = ArgonName("")
    public var keyAsPointer = wordAsPointer(Word(Argon.nextCounter))
    public private(set) var id:Int
    
    public var isSystemTraits:Bool
        {
        return(false)
        }
    
    public var isVariable:Bool
        {
        return(false)
        }
    
    public var isParameter:Bool
        {
        return(false)
        }
    
    public var isTemporary:Bool
        {
        return(false)
        }
    
    public var isStackBased:Bool
        {
        return(false)
        }
    
    public var isInteger:Bool
        {
        return(false)
        }
    
    public var firstSlotOffset:Int
        {
        return(24)
        }
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(self)
            }
        set
            {
            }
        }
    
    @discardableResult
    public func asArgonTraits() -> ArgonTraits
        {
        if let traits = ArgonRelocationTable.shared.traits(at: self.fullName.string)
            {
            return(traits)
            }
        let newTraits = ArgonTraits(fullName: self.fullName.string)
        for aSlot in self.slotLayouts.values.map({ArgonSlotLayout(name: $0.name,offsetInInstance: $0.offsetInInstance,traits: $0.traits.asArgonTraits())})
            {
            newTraits.slotLayouts[aSlot.name] = aSlot
            }
        newTraits.parents = self.parents.map{$0.asArgonTraits()}
        newTraits.typeTemplates = self.typeTemplates.map{$0.asArgonTypeTemplate()}
        newTraits.id = self.id
        ArgonRelocationTable.shared.register(traits: newTraits)
        return(newTraits)
        }
    
    public var metaTraits:ArgonMetaTraitsNode
        {
        return(ArgonMetaTraitsNode(fullName: ArgonName(self.fullName.string + "MetaTraits"),instanceTraits: self))
        }
        
    public var totalSlotCount:Int
        {
        return(self.totalSlots().count)
        }
    
    public override var hashValue:Int
        {
        return(name.string.hashValue)
        }
    
    public override var isTraits:Bool
        {
        return(true)
        }
    
    public var isVoid:Bool
        {
        return(self == ArgonStandardsNode.shared.voidTraits)
        }
    
    public override var isType:Bool
        {
        return(true)
        }
        
    public override var isValidSlotType:Bool
        {
        return(true)
        }
    
    init(fullName:ArgonName)
        {
        self.id = Argon.nextCounter
        super.init()
        self.fullName = fullName
        self.name = ArgonName(fullName.last)
        }

    
    public func doesNotContainTypeTemplate(named:ArgonName) -> Bool
        {
        for template in typeTemplates
            {
            if template.name == named
                {
                return(false)
                }
            }
        return(true)
        }
    
    public func subTraits(of upper: ArgonTraitsNode) -> Bool
        {
        if upper == self
            {
            return(true)
            }
        for parent in parents
            {
            if parent == upper
                {
                return(true)
                }
            if parent.subTraits(of:upper)
                {
                return(true)
                }
            }
        return(false)
        }
    
    public func inherits(from:ArgonTraitsNode) -> Bool
        {
        if self.name == from.name
            {
            return(true)
            }
        for parent in parents
            {
            if parent.inherits(from: from)
                {
                return(true)
                }
            }
        return(false)
        }
    
    public func isInInheritanceGraph(of: ArgonTraitsNode) -> Bool
        {
        if self.inherits(from: of)
            {
            return(true)
            }
        else if of.inherits(from: self)
            {
            return(true)
            }
        return(false)
        }
    
    public func distance(to traits:ArgonTraitsNode) -> Int?
        {
        if !self.subTraits(of: traits)
            {
            return(nil)
            }
        if traits == self
            {
            return(0)
            }
        for parent in parents
            {
            if parent.inherits(from: traits)
                {
                return(1 + parent.distance(to: traits)!)
                }
            }
        return(-1)
        }
    
    public func enclosingWith() -> ArgonWithStatementNode?
        {
        return(containingScope?.enclosingWith())
        }
    
    public func add(typeTemplate:ArgonTypeTemplateNode)
        {
        typeTemplates.append(typeTemplate)
        }
    
    public func scopeName() -> ArgonName
        {
        return(containingScope!.scopeName() + self.name)
        }
    
    public func add(node: ArgonParseNode)
        {
        }
    
    public func add(slot:ArgonSlotNode)
        {
        slots.append(slot)
        slot.containingTraits = self
        }
    
    public func add(variable: ArgonVariableNode)
        {
        guard let local = variable as? ArgonLocalVariableNode else
            {
            fatalError("Only locals can be added to traits")
            }
        local.scopedName = self.scopeName() + local.name
        }
    
    public func add(statement: ArgonMethodStatementNode)
        {
        }
    
    public func add(constant: ArgonNamedConstantNode)
        {
        }
        
    public func add(method: ArgonTraitsMethodNode)
        {
        methods[method.name] = method
        }
    
    private func allParents() -> [ArgonTraitsNode]
        {
        var allParents:[ArgonTraitsNode] = []
        for parent in parents
            {
            if !allParents.contains(parent)
                {
                allParents.append(parent)
                }
            for anotherParent in parent.allParents()
                {
                if !allParents.contains(anotherParent)
                    {
                    allParents.append(anotherParent)
                    }
                }
            }
        return(allParents)
        }
    
    private func allParentSlots() -> ArgonSlotList
        {
        var allSlots = slots
        for parent in parents
            {
            allSlots.append(contentsOf: parent.allParentSlots())
            }
        return(allSlots)
        }
    
    public func enclosingScope() -> ArgonParseScope?
        {
        return(containingScope)
        }
    
    public func resolveSlotsAndTypeTemplates() throws
        {
        var allSlots = ArgonSlotList()
        for parent in parents
            {
            allSlots.append(contentsOf: parent.allParentSlots())
            }
        for slot in allSlots
            {
            self.slots.append(slot)
            }
        let templatedSlots = self.slots.filter {$0.type.isTypeTemplate}
        for slot in templatedSlots
            {
            let typeName = slot.type.name
            if let actualType = self.resolve(name: typeName) as? ArgonTypeTemplateInstanceNode
                {
                guard let realType = actualType.instantiatedType else
                    {
                    throw(ParseError.invalidType(typeName.string))
                    }
                slot.type = realType
                }
            }
        var offset = self.firstSlotOffset
        for slot in slots
            {
            if !slot.type.isTemplateType || (slot.type.isTemplateType && !slot.type.isHollowTemplateType)
                {
                let layout = ArgonSlotLayoutNode(name: slot.name.string, offset: offset, traits: slot.traits)
                slotLayouts[ArgonName(layout.name)] = layout
                offset += 8
                }
            }
        }
    
    public override func resolve(name:ArgonName) -> ArgonParseNode?
        {
        if let slot = slots[name]
            {
            return(slot)
            }
        for type in typeTemplates
            {
            if type.name == name
                {
                return(type)
                }
            }
        for parent in parents
            {
            if parent is ArgonSystemTraitsNode
                {
                (parent as! ArgonSystemTraitsNode).containingScope = containingScope
                }
            let parentItem = parent.resolve(name: name)
            if parentItem != nil
                {
                return(parentItem!)
                }
            }
        if let method = methods[name]
            {
            return(method)
            }
        return(containingScope?.resolve(name: name))
        }
    
    public func localSlots() -> ArgonSlotList
        {
        return(slots)
        }
    
    public func localAndInheritedSlots() -> ArgonSlotList
        {
        var allSlots = slots
        for parent in parents
            {
            allSlots.append(contentsOf: parent.localAndInheritedSlots())
            }
        return(allSlots)
        }
    
    public func slot(named:ArgonName) -> ArgonSlotNode?
        {
        if let slot = slots[named]
            {
            return(slot)
            }
        for parent in parents
            {
            if let slot = parent.slot(named:named)
                {
                return(slot)
                }
            }
        return(nil)
        }
    
    public func enclosingMethod() -> ArgonMethodNode?
        {
        return(containingScope!.enclosingMethod())
        }
    
    public func enclosingModule() -> ArgonParseModule
        {
        return(containingScope!.enclosingModule())
        }
    
    public func totalSlots() -> ArgonSlotList
        {
        var totalSlots = ArgonSlotList()
        
        totalSlots = slots
        for parent in parents
            {
            totalSlots.append(contentsOf: parent.totalSlots())
            }
        return(totalSlots)
        }
    
    public func unify(with traits:ArgonTraitsNode) -> Bool
        {
        if self == traits
            {
            return(true)
            }
        if traits.inherits(from: self)
            {
            return(true)
            }
        return(false)
        }
        
    public func slotLayout(forSlotNamed name:ArgonName) -> ArgonSlotLayoutNode?
        {
        return(slotLayouts[name])
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        }
    }
