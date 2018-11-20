//
//  ArgonClosureCallNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonClosureCallNode:ArgonMethodStatementNode
    {
    public private(set) var lhs:ArgonVariableNode?
    public private(set) var closure:ArgonClosureNode
    public private(set) var arguments:[ArgonParameterValueNode] = []
    
    init(lhs:ArgonVariableNode?,closure:ArgonClosureNode,arguments:[ArgonParameterValueNode])
        {
        self.lhs = lhs
        self.closure = closure
        self.arguments = arguments
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        for argument in arguments.reversed()
            {
            if argument.valueExpression is ThreeAddress
                {
                pass.add(ThreeAddressInstruction(operation: .param,operand1: argument.valueExpression as! ThreeAddress))
                }
            else
                {
                try argument.valueExpression.threeAddress(pass: pass)
                pass.add(ThreeAddressInstruction(operation: .param,operand1: pass.lastLHS()))
                }
            }
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .call,target: closure as ThreeAddress))
        pass.add(ThreeAddressInstruction(operation: .clear,operand1:arguments.count as ThreeAddress))
        }
    }
