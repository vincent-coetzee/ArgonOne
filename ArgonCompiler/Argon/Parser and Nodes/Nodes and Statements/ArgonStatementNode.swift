//
//  ArgonStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/10.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonStatementNode:ArgonParseNode
    {
    public var lineTrace:ArgonLineTrace?
    
    public var isReturnStatement:Bool
        {
        return(false)
        }
    
    public func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return([])
        }
    
    public func allLocals() -> [ArgonLocalVariableNode]
        {
        return([])
        }
    }
