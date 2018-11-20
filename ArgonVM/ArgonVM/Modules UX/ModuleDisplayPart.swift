//
//  ModuleDisplayPart.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public protocol ModuleDisplayPart
    {
    var childCount:Int { get }
    var children:[ModuleDisplayPart] { get }
    var title:String { get }
    var icon:NSImage { get }
    var codeBlock:Pointer? { get }
    }

public class ModulePartHolder:ModuleDisplayPart
    {
    public var modulePart:ArgonModulePart
    public var _title:String?
    public var _children:[ModuleDisplayPart]?
    public var _icon:NSImage?
    public var _codeBlock:Pointer?
    
    public var codeBlock:Pointer?
        {
        if _codeBlock != nil
            {
            return(_codeBlock)
            }
        else if modulePart is ArgonClosure
            {
            let part = modulePart as! ArgonClosure
            return(ClosurePointerWrapper(part.pointer).codeBlockPointer)
            }
        return(nil)
        }
    
    init(part:ArgonModulePart)
        {
        self.modulePart = part
        }
    
    init(title:String,icon:NSImage,children:[ModuleDisplayPart],codeBlock:Pointer?)
        {
        _title = title
        _children = children
        _icon = icon
        _codeBlock = codeBlock
        modulePart = ArgonModule(fullName:"")
        }
    
    public var childCount:Int
        {
        if modulePart is ArgonGenericMethod
            {
            let part = modulePart as! ArgonGenericMethod
            return(part.instances.count)
            }
        if modulePart is ArgonExecutable
            {
            let part = modulePart as! ArgonExecutable
            return(part.subParts.count + 1)
            }
        if _children != nil
            {
            return(_children!.count)
            }
        return(0)
        }
    
    public var children:[ModuleDisplayPart]
        {
        if modulePart is ArgonGenericMethod
            {
            let part = modulePart as! ArgonGenericMethod
            return(part.instances.map{ModulePartHolder(title: $0.fullName,icon:NSImage(named:"ArgonMethodIcon")!,children:[],codeBlock: MethodPointerWrapper($0.pointer).codeBlockPointer)})
            }
        if let part = modulePart as? ArgonExecutable
            {
            let subParts = part.subParts
            var parts = subParts.map{ModulePartHolder(part: $0)}
            parts.append(ModulePartHolder(title:"EntryPoint",icon:NSImage(named:"ArgonEntryPointIcon")!,children:[],codeBlock: part.entryPointCodePointer))
            return(parts.sorted(by: {$0.title < $1.title}))
            }
        else if _children != nil
            {
            return(_children!)
            }
        return([])
        }
    
    public var title:String
        {
        if _title != nil
            {
            return(_title!)
            }
        return(modulePart.fullName)
        }
    
    public var icon:NSImage
        {
        if _icon != nil
            {
            return(_icon!)
            }
        switch(modulePart)
            {
            case is ArgonExecutable:
                return(NSImage(named:"ArgonExecutableIcon")!)
             case is ArgonLibrary:
                return(NSImage(named:"ArgonLibraryIcon")!)
             case is ArgonTraits:
                return(NSImage(named:"ArgonTraitsIcon")!)
             case is ArgonGenericMethod:
                return(NSImage(named:"ArgonGenericMethodIcon")!)
             case is ArgonNamedConstant:
                return(NSImage(named:"ArgonConstantIcon")!)
             case is ArgonGlobal:
                return(NSImage(named:"ArgonGlobalIcon")!)
             case is ArgonClosure:
                return(NSImage(named:"ArgonClosureIcon")!)
            default:
                fatalError("Invalid class")
            }
        }
    }
