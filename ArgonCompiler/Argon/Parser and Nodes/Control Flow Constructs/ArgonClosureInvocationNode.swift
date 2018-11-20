//
//  ArgonClosureInvocationNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/08.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonClosureInvocationNode:ArgonExpressionNode
    {
    public private(set) var closure:ArgonClosureNode?
    public private(set) var closureStore:ArgonStoredValueNode?
    public var arguments:[ArgonParameterValueNode] = []
    public var lineTrace:ArgonLineTrace?
    
    public override var isOrContainsClosure:Bool
        {
        return(true)
        }
    
    init(closure:ArgonClosureNode,arguments:[ArgonParameterValueNode])
        {
        self.closure = closure
        self.arguments = arguments
        super.init()
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
        let temporary = pass.newTemporary()
        let instruction = ThreeAddressInstruction(lhs: temporary,operation: .call,target: (closure as! ThreeAddress))
        print(instruction)
        pass.add(instruction)
        }
    }
