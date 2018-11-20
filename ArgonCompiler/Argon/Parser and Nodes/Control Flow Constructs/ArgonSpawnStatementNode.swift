//
//  ArgonForkStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSpawnStatementNode:ArgonMethodStatementNode
    {
    public private(set) var closure:ArgonClosureNode
    public var arguments:[ArgonParameterValueNode] = []
    
    init(closure:ArgonClosureNode)
        {
        self.closure = closure
        super.init()
        }
    
    init(localContainingClosure local:ArgonLocalVariableNode) throws
        {
        guard local.containsClosure else
            {
            throw(ParseError.localDoesNotContainClosure)
            }
        self.closure = (local as! ArgonClosureVariableNode).closure
        super.init()
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        for argument in arguments.reversed()
            {
            var value:ThreeAddress
            if argument.valueExpression is ThreeAddress
                {
                value = argument.valueExpression as! ThreeAddress
                }
            else
                {
                try argument.valueExpression.threeAddress(pass: pass)
                value = pass.lastLHS()
                }
            pass.add(ThreeAddressInstruction(operation: .param,operand1:value))
            }
        pass.add(ThreeAddressInstruction(operation: .spawn,operand1:closure))
        }
    }
