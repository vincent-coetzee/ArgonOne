//
//  ArgonTopLevelNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/10.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonTopLevelNode:ArgonScopeNode,ArgonParseModule,ArgonParseScope
    {
    public static var current:ArgonParseModule!
    
    public var enclosingStackFrame:ArgonStackFrame? = nil
    public var statements = ArgonStatementList()
    public var constants:[ArgonNamedConstantNode] = []
    public var globals:[ArgonGlobalVariableNode] = []
    
    override init(name:ArgonName)
        {
        super.init(name:name)
        ArgonTopLevelNode.current = self
        }
    
    public func isGlobalScope() -> Bool
        {
        return(true)
        }
    
   public override func add(variable:ArgonVariableNode)
        {
        guard let global = variable as? ArgonGlobalVariableNode else
            {
            fatalError("Only globals can be added here")
            }
        globals.append(global)
        }
    
    public func enclosingWith() -> ArgonWithStatementNode?
        {
        return(nil)
        }
    
    public func enclosingMethod() -> ArgonMethodNode?
        {
        return(nil)
        }
        
    public func add(constant: ArgonNamedConstantNode)
        {
        constants.append(constant)
        }
    
    public func scopeName() -> ArgonName
        {
        return(self.moduleName)
        }
    
    public override func resolve(name:ArgonName) -> ArgonParseNode?
        {
        for constant in constants
            {
            if constant.name == name
                {
                return(constant)
                }
            }
        for global in globals
            {
            if global.name == name
                {
                return(global)
                }
            }
        guard let type = keyedTypes[name] else
            {
            return(containingScope?.resolve(name:name))
            }
        return(type)
        }
    
    public func add(statement:ArgonMethodStatementNode)
        {
        statements.append(statement)
        }
    
    public var moduleName:ArgonName
        {
        return(name)
        }
        
    public func enclosingModule() -> ArgonParseModule
        {
        return(self)
        }
    
    public func fixupReferences() throws
        {
        }
        
    public func enclosingScope() -> ArgonParseScope?
        {
        return(containingScope)
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        for global in globals
            {
            try global.threeAddress(pass: pass)
            }
        try statements.threeAddress(pass: pass)
        }
    
    public func allMethods() -> [ArgonMethodNode]
        {
        let generics = keyedTypes.values.filter { $0.isMethod }
        let instances = generics.flatMap {($0 as! ArgonGenericMethodNode).instances}
        return(instances)
        }
    
    public func allLocals() -> [ArgonLocalVariableNode]
        {
        var localList = self.locals
        for method in self.allMethods()
            {
            localList.append(contentsOf: method.allLocals())
            }
        return(localList)
        }
    
    public func allTraits() -> [ArgonTraitsNode]
        {
        return(keyedTypes.values.filter { $0.isTraits } as! [ArgonTraitsNode])
        }
    }
