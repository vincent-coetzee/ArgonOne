//
//  ArgonRelocationTable.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public typealias ArgonRelocationEntryConversion = () -> ArgonRelocatable

public class ArgonRelocationTableEntry:NSObject,NSCoding
    {
    public static func ==(lhs:ArgonRelocationTableEntry,rhs:ArgonRelocationTableEntry) -> Bool
        {
        if lhs.kind != rhs.kind
            {
            return(false)
            }
        if lhs.kind == .string
            {
            return((lhs.item as! String) == (rhs.item as! String))
            }
        if lhs.kind == .global
            {
            return((lhs.item as! ArgonGlobal).name == (rhs.item as! ArgonGlobal).name)
            }
        if lhs.kind == .symbol
            {
            return((lhs.item as! ArgonSymbol).string == (rhs.item as! ArgonSymbol).string)
            }
        if lhs.kind == .traits
            {
            return((lhs.item as! ArgonTraits).fullName == (rhs.item as! ArgonTraits).fullName)
            }
        if lhs.kind == .genericMethod
            {
            return((lhs.item as! ArgonGenericMethod).fullName == (rhs.item as! ArgonGenericMethod).fullName)
            }
        if lhs.kind == .constant
            {
            return((lhs.item as! ArgonNamedConstant).fullName == (rhs.item as! ArgonNamedConstant).fullName)
            }
        if lhs.kind == .handler
            {
            return((lhs.item as! ArgonHandler).id == (rhs.item as! ArgonHandler).id)
            }
        return(false)
        }
    
    public var closure:ArgonClosure
        {
        return(item as! ArgonClosure)
        }
    
    public var global:ArgonGlobal
        {
        return(item as! ArgonGlobal)
        }
    
    public var string:ArgonString
        {
        return(item as! ArgonString)
        }
    
    public var symbol:ArgonSymbol
        {
        return(item as! ArgonSymbol)
        }
    
    public var traits:ArgonTraits
        {
        return(item as! ArgonTraits)
        }
    
    public var genericMethod:ArgonGenericMethod
        {
        return(item as! ArgonGenericMethod)
        }
    
    public var handler:ArgonHandler
        {
        return(item as! ArgonHandler)
        }
    
    public var item:Any
    public var kind:ArgonModuleItemKind = .none
    public var labels:[String] = []
    public var pointer:Pointer?
    
    init(closure:ArgonClosure)
        {
        item = closure
        kind = .closure
        }
    
    init(traits:ArgonTraits)
        {
        item = traits
        kind = .traits
        }
    
    init(string:ArgonString)
        {
        item = string
        kind = .string
        }
    
    init(symbol:ArgonString)
        {
        item = symbol
        kind = .symbol
        }
    
    init(genericMethod:ArgonGenericMethod)
        {
        item = genericMethod
        kind = .genericMethod
        }
    
    init(global:ArgonGlobal)
        {
        item = global
        kind = .global
        }
    
    init(handler:ArgonHandler)
        {
        item = handler
        kind = .handler
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(kind.rawValue,forKey:"kind")
        aCoder.encode(item,forKey:"item")
        aCoder.encode(labels,forKey:"labels")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        self.kind = ArgonModuleItemKind(rawValue: aDecoder.decodeInteger(forKey:"kind"))!
        self.item = aDecoder.decodeObject(forKey:"item")!
        self.labels = aDecoder.decodeObject(forKey:"labels") as! [String]
        }
    }

public class ArgonRelocationTable:NSObject,NSCoding
    {
    public static let shared = ArgonRelocationTable()
    public private(set) var traitsByFullName:[String:ArgonTraits] = [:]
    public private(set) var entriesByPart:[Int:ArgonRelocationTableEntry] = [:]
    public private(set) var closures:[(String,ArgonRelocationEntryConversion)] = []
    public private(set) var entries:[ArgonRelocationTableEntry] = []
    
    public func traits(at name:String) -> ArgonTraits?
        {
        return(traitsByFullName[name])
        }
    
    public func register(traits:ArgonTraits)
        {
        traitsByFullName[traits.fullName] = traits
        if entriesByPart[traits.id] == nil
            {
            let entry = ArgonRelocationTableEntry(traits:traits)
            entriesByPart[traits.id] = entry
            }
        }
    
    public func buildRelocationEntries()
        {
        for (label,closure) in closures
            {
            let part = closure()
            switch(part)
                {
                case is ArgonHandler:
                    let piece = part as! ArgonHandler
                    if let entry = entriesByPart[piece.id]
                        {
                        entry.labels.append(label)
                        }
                    else
                        {
                        let entry = ArgonRelocationTableEntry(handler: piece)
                        entriesByPart[piece.id] = entry
                        entry.labels.append(label)
                        }
                case is ArgonClosure:
                    let piece = part as! ArgonClosure
                    if let entry = entriesByPart[piece.id]
                        {
                        entry.labels.append(label)
                        }
                    else
                        {
                        let entry = ArgonRelocationTableEntry(closure: piece)
                        entriesByPart[piece.id] = entry
                        entry.labels.append(label)
                        }
                case is ArgonTraits:
                    let piece = part as! ArgonTraits
                    if let entry = entriesByPart[piece.id]
                        {
                        entry.labels.append(label)
                        }
                    else
                        {
                        let entry = ArgonRelocationTableEntry(traits: piece)
                        entriesByPart[piece.id] = entry
                        entry.labels.append(label)
                        }
                case is ArgonGenericMethod:
                    let piece = part as! ArgonGenericMethod
                    if let entry = entriesByPart[piece.id]
                        {
                        entry.labels.append(label)
                        }
                    else
                        {
                        let entry = ArgonRelocationTableEntry(genericMethod: piece)
                        entriesByPart[piece.id] = entry
                        entry.labels.append(label)
                        }
                case is ArgonGlobal:
                    let piece = part as! ArgonGlobal
                    if let entry = entriesByPart[piece.id]
                        {
                        entry.labels.append(label)
                        }
                    else
                        {
                        let entry = ArgonRelocationTableEntry(global: piece)
                        entriesByPart[piece.id] = entry
                        entry.labels.append(label)
                        }
                case is ArgonString:
                    let piece = part as! ArgonString
                    if let entry = entriesByPart[piece.id]
                        {
                        entry.labels.append(label)
                        }
                    else
                        {
                        let entry = ArgonRelocationTableEntry(string: piece)
                        entriesByPart[piece.id] = entry
                        entry.labels.append(label)
                        }
                default:
                    break
                }
            }
        self.entries = Array(entriesByPart.values)
        }
    
    public func relocate(_ item:@escaping ArgonRelocationEntryConversion,at label:String)
        {
        closures.append((label,item))
        }
    
    public override init()
        {
        }
        
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(entries,forKey:"entries")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        self.entries = aDecoder.decodeObject(forKey:"entries") as! [ArgonRelocationTableEntry]
        }
    }
