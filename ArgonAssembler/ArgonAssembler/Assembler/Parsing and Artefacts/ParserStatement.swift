//
//  ParserStatement.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ParserStatement:ParserNode
    {
    public var line:Int = 0
    public var label:String? = nil
    
    public private(set) var opcode:Keyword
    
    init(opcode: Keyword)
        {
        self.opcode = opcode
        }
    }
