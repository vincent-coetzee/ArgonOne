//
//  ArgonParseNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonParseNode:ArgonCompilationUnit
    {
    public var sourceLocation:SourceLocation?

    public var traits:ArgonTraitsNode
        {
        return(ArgonStandardsNode.shared.voidTraits)
        }
    
    public var isImportNode:Bool
        {
        return(false)
        }
    
    public var isNamedConstant:Bool
        {
        return(false)
        }
    
    public var isLocal:Bool
        {
        return(false)
        }
    
    public var isOrContainsClosure:Bool
        {
        return(false)
        }
        
    public var isClosure:Bool
        {
        return(false)
        }
    
    public var isExportNode:Bool
        {
        return(false)
        }
    
    public var isTraits:Bool
        {
        return(false)
        }
    
    public var isGenericMethod:Bool
        {
        return(false)
        }
    
    public var isValidSlotType:Bool
        {
        return(false)
        }
    
    public var isTypeTemplate:Bool
        {
        return(false)
        }
    
    public var isTypeTemplateInstance:Bool
        {
        return(false)
        }
    
    public var isType:Bool
        {
        return(false)
        }
    
    public var isGeneric:Bool
        {
        return(false)
        }
    
    public var isStoredValue:Bool
        {
        return(false)
        }
    
    public var isObject:Bool
        {
        return(false)
        }
    
    public var isImport:Bool
        {
        return(false)
        }
    
    public var isExport:Bool
        {
        return(false)
        }
    
    public var isMethod:Bool
        {
        return(false)
        }
    
    public var isSlot:Bool
        {
        return(false)
        }
    
    public var isGlobal:Bool
        {
        return(false)
        }
    
    public func resolve(name:ArgonName) -> ArgonParseNode?
        {
        return(nil)
        }
    
    public var isTemplateVariable:Bool
        {
        return(false)
        }
    
    public func threeAddress(pass:ThreeAddressPass) throws
        {
        fatalError("This should not be called")
        }
    }
