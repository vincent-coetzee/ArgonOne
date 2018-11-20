//
//  ArgonCompoundMethodStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonCompoundMethodStatementNode:ArgonMethodStatementNode,ArgonParseScope
    {
    internal var containingScope:ArgonParseScope
    internal var statements = ArgonStatementList()
    internal var symbols:[ArgonName:ArgonNamedNode] = [:]
    public var locals:[ArgonLocalVariableNode] = []
    public var enclosingStackFrame:ArgonStackFrame?
    public var label:String = ""
    public var constants:[ArgonNamedConstantNode] = []
    
    
    init(containingScope:ArgonParseScope)
        {
        self.containingScope = containingScope
        }
    
    public override func allLocals() -> [ArgonLocalVariableNode]
        {
        var localList = self.locals
        localList.append(contentsOf: statements.allLocals())
        return(localList)
        }
    
    public func add(statement:ArgonMethodStatementNode)
        {
        statements.append(statement)
        }
        
    public func add(constant:ArgonNamedConstantNode)
        {
        constants.append(constant)
        }
    
    public func enclosingWith() -> ArgonWithStatementNode?
        {
        return(containingScope.enclosingWith())
        }
    
    public func enclosingMethod() -> ArgonMethodNode?
        {
        return(containingScope.enclosingMethod())
        }
    
    public func enclosingModule() -> ArgonParseModule
        {
        return(containingScope.enclosingModule())
        }
    
   public func enclosingScope() -> ArgonParseScope?
        {
        return(containingScope)
        }
    
    public func scopeName() -> ArgonName
        {
        return(containingScope.scopeName() + ArgonName("\(type(of: self))"))
        }
    
    public override func resolve(name: ArgonName) -> ArgonParseNode?
        {
        for constant in constants
            {
            if constant.name == name
                {
                return(constant)
                }
            }
        for local in locals
            {
            if local.name == name
                {
                return(local)
                }
            }
        if let item = symbols[name]
            {
            return(item)
            }
        return(containingScope.resolve(name:name))
        }
    
    public func add(node: ArgonParseNode)
        {
        fatalError()
        }
    
    public func add(variable: ArgonVariableNode)
        {
        guard let local = variable as? ArgonLocalVariableNode else
            {
            fatalError("Only locals can be added here")
            }
        locals.append(local)
        local.scopedName = self.scopeName() + local.name.string
        }

    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var offset = -8
        for local in locals
            {
            local.offsetFromBP = offset
            offset -= 8
            }
        if lineTrace != nil
            {
            pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
            }
        try statements.threeAddress(pass: pass)
        }
    }
