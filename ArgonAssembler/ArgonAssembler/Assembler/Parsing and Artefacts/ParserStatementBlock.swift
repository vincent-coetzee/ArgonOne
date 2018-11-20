//
//  ParserStatementBlock.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ParserStatementBlock:ParserNode
    {
    public let line = 0
    public let label:String? = nil
    private var statements:[ParserStatement] = []
    
    public mutating func add(statement:ParserStatement)
        {
        statements.append(statement)
        }
    }
