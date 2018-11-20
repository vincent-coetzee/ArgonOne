//
//  ArgonParseScope.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonParseScope
    {
    func enclosingMethod() -> ArgonMethodNode?
    func enclosingModule() -> ArgonParseModule
    func enclosingClosure() -> ArgonClosureNode?
    func add(node:ArgonParseNode)
    func add(variable:ArgonVariableNode)
    func add(statement: ArgonMethodStatementNode)
    func add(constant: ArgonNamedConstantNode)
    func enclosingScope() -> ArgonParseScope?
    func enclosingWith() -> ArgonWithStatementNode?
    func resolve(name: ArgonName) -> ArgonParseNode?
    func scopeName() -> ArgonName
    func isGlobalScope() -> Bool
    }

extension ArgonParseScope
    {
    public func isGlobalScope() -> Bool
        {
        return(false)
        }
    
    public func enclosingClosure() -> ArgonClosureNode?
        {
        return(nil)
        }
    }
