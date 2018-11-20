//
//  ArgonStatementList.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/08.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonStatementList
    {
    private var statements:[ArgonMethodStatementNode] = []
    
    public var count:Int
        {
        return(statements.count)
        }
    
    public func threeAddress(pass:ThreeAddressPass) throws
        {
        for statement in statements
            {
            try statement.threeAddress(pass: pass)
            }
        }
    
    public func append(_ statement:ArgonMethodStatementNode)
        {
        statements.append(statement)
        }

    public func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return(statements.flatMap {$0.touchedStoredValues()})
        }
    
    public func allLocals() -> [ArgonLocalVariableNode]
        {
        var localList = Array<ArgonLocalVariableNode>()
        for statement in statements
            {
            localList.append(contentsOf: statement.allLocals())
            }
        return(localList)
        }
    }
