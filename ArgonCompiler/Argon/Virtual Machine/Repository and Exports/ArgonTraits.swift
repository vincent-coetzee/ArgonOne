//
//  ArgonTraits.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonSlotLayout:NSObject,NSCoding,FileWritable
    {
    public private(set) var name:String
    public private(set) var offsetInInstance:Int
    public private(set) var traits:ArgonTraits
    public var pointer:Pointer = wordAsPointer(0)
    
    public init(name:String,offsetInInstance:Int,traits:ArgonTraits)
        {
        self.name = name
        self.offsetInInstance = offsetInInstance
        self.traits = traits
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(name,forKey:"name")
        aCoder.encode(offsetInInstance,forKey:"offsetInInstance")
        aCoder.encode(traits,forKey:"traits")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        self.traits = aDecoder.decodeObject(forKey:"traits") as! ArgonTraits
        self.offsetInInstance = aDecoder.decodeInteger(forKey:"offsetInInstance")
        self.name = aDecoder.decodeObject(forKey:"name") as! String
        }
    
    required public init(archiver: CArchiver) throws
        {
        name = try String(archiver: archiver)
        offsetInInstance = try Int(archiver: archiver)
        traits = try ArgonTraits(archiver: archiver)
        }
    
    public func write(archiver: CArchiver) throws
        {
        try name.write(archiver: archiver)
        try offsetInInstance.write(archiver: archiver)
        try traits.write(archiver: archiver)
        }
    }

extension Array where Element == ArgonTraits
    {
    public func containsOne(of roots: Array<ArgonTraits>) -> Bool
        {
        for element in roots
            {
            for innerElement in self
                {
                if element == innerElement
                    {
                    return(true)
                    }
                }
            }
        return(false)
        }
    }

public class ArgonTraits:ArgonModulePart
    {
    public static func orderTraitsByInheritance(_ traits:[ArgonTraits]) -> [ArgonTraits]
        {
        var list = traits
        var levels:[[ArgonTraits]] = []
        // find all classes with no parents
        var parents = traits.filter{$0.parents.count == 0}
        levels.append(parents)
        list.removeAll(where: {parents.contains($0)})
        while !list.isEmpty
            {
            let level = self.traitsHavingParents(in: parents,from:&list)
            levels.append(level)
            parents = level
            }
        var result:[ArgonTraits] = []
        for some in levels
            {
            result.append(contentsOf: some)
            }
        return(result)
        }
    
    private static func traitsHavingParents(in roots: [ArgonTraits],from list:inout [ArgonTraits]) -> [ArgonTraits]
        {
        let traits = list.filter{$0.parents.containsOne(of: roots)}
        list.removeAll(where: {traits.contains($0)})
        return(traits)
        }
    
    private static var wasInitialized = false
    
    public var kind: ArgonModuleItemKind = .traits
    public var parents:[ArgonTraits] = []
    public var slotLayouts:[String:ArgonSlotLayout] = [:]
    public var typeTemplates:[ArgonTypeTemplate] = []
    
    public override init(fullName:String)
        {
        super.init(fullName: fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(slotLayouts,forKey:"slotLayouts")
        aCoder.encode(parents,forKey:"parents")
        aCoder.encode(kind.rawValue,forKey:"kind")
        aCoder.encode(typeTemplates,forKey:"typeTemplates")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        slotLayouts = aDecoder.decodeObject(forKey: "slotLayouts") as! [String:ArgonSlotLayout]
        parents = aDecoder.decodeObject(forKey: "parents") as! [ArgonTraits]
        typeTemplates = aDecoder.decodeObject(forKey: "typeTemplates") as! [ArgonTypeTemplate]
        kind = ArgonModuleItemKind(rawValue:aDecoder.decodeInteger(forKey: "kind"))!
        super.init(coder: aDecoder)
        }
    
    required public init(archiver: CArchiver) throws
        {
        let layouts = try [ArgonSlotLayout](archiver: archiver)
        slotLayouts = [:]
        for slot in layouts
            {
            slotLayouts[slot.name] = slot
            }
        parents = try [ArgonTraits](archiver: archiver)
        typeTemplates = try [ArgonTypeTemplate](archiver: archiver)
        kind = try ArgonModuleItemKind(archiver: archiver)
        try super.init(archiver: archiver)
        }
    
    public override func write(archiver: CArchiver) throws
        {
        try archiver.write(object: self)
        try super.write(archiver: archiver)
        try Array(slotLayouts.values).write(archiver: archiver)
        try parents.write(archiver: archiver)
        try typeTemplates.write(archiver: archiver)
        try kind.write(archiver: archiver)
        }
    
    public func inherits(from: ArgonTraits) -> Bool
        {
        if self == from
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
    
    public func inheritsDirectly(from: ArgonTraits) -> Bool
        {
        for parent in parents
            {
            if parent == from
                {
                return(true)
                }
            }
        return(false)
        }
    }

public class ArgonTypeTemplate:NSObject,NSCoding,FileWritable
    {
    public static func ==(lhs:ArgonTypeTemplate,rhs:ArgonTypeTemplate) -> Bool
        {
        return(lhs.name == rhs.name)
        }
    
    public var name:String = ""
    public var traits:ArgonTraits
    public var definingTraits = "Argon::Void"
    
    init(name: String)
        {
        self.traits = ArgonRelocationTable.shared.traits(at:"Argon::Traits")!
        self.name = name
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(name,forKey:"name")
        aCoder.encode(traits,forKey:"traits")
        aCoder.encode(definingTraits,forKey:"definingTraits")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        name = aDecoder.decodeObject(forKey: "name") as! String
        traits = aDecoder.decodeObject(forKey: "traits") as! ArgonTraits
        definingTraits = aDecoder.decodeObject(forKey: "definingTraits") as! String
        }
    
    required public init(archiver: CArchiver) throws
        {
        name = try String(archiver: archiver)
        traits = try ArgonTraits(archiver: archiver)
        definingTraits = try String(archiver: archiver)
        try super.init()
        }
    
    public func write(archiver: CArchiver) throws
        {
        try name.write(archiver: archiver)
        try traits.write(archiver: archiver)
        try definingTraits.write(archiver: archiver)
        }
    }
