//
//  ArgonCompilerSymbolTable.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSymbolTableEntry
    {
    public private(set) var name:ArgonName = ArgonName()
    public private(set) var node:ArgonParseNode
    public var isAlive:Bool = true
    public var nextUseInstruction:ThreeAddressInstruction? = nil
    
    init(name:ArgonName,node:ArgonParseNode)
        {
        self.name = name
        self.node = node
        }
    }

public class ArgonSymbolTable
    {
    private var symbols:[ArgonName:ArgonSymbolTableEntry] = [:]
    
    public func symbol(at name:ArgonName) -> ArgonParseNode?
        {
        guard let symbol = symbols[name] else
            {
            return(ArgonStandardsNode.shared.symbol(at: name))
            }
        return(symbol.node)
        }
    
    public func add(variable:ArgonVariableNode,at name: ArgonName) -> ArgonSymbolTableEntry
        {
        let entry = ArgonSymbolTableEntry(name:name,node:variable)
        self.symbols[name] = entry
        return(entry)
        }
    
    public func add(constant:ArgonNamedConstantNode,at name: ArgonName) -> ArgonSymbolTableEntry
        {
        let entry = ArgonSymbolTableEntry(name:name,node:constant)
        self.symbols[name] = entry
        return(entry)
        }
    
    public func dump()
        {
        for (key,value) in symbols
            {
            print("KEY = \(key) \(value)")
            }
        }
    }
