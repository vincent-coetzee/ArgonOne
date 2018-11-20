//
//  ArgonNextMethodStatement.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonNextMethodStatementNode:ArgonMethodStatementNode
    {
    public var currentParameters:[ArgonParameterNode] = []
    public var currentMethod:ArgonMethodNode
    
    public init(parameters:[ArgonParameterNode],method:ArgonMethodNode)
        {
        currentParameters = parameters
        currentMethod = method
        super.init()
        }
    }
