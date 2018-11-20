//
//  ArgonLocalInitializationStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/08.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonVariableInitializationStatementNode:ArgonMethodStatementNode
    {
    public private(set) var name:ArgonName
    public private(set) var _traits:ArgonTraitsNode?
    public private(set) var variable:ArgonVariableNode
    public private(set) var value:ArgonExpressionNode
    
    init(name:ArgonName,traits:ArgonTraitsNode?,value:ArgonExpressionNode,variable:ArgonVariableNode)
        {
        self.name = name
        self._traits = traits
        self.value = value
        self.variable = variable
        if _traits == nil
            {
            variable.traits = value.traits
            }
        else
            {
            variable.traits = _traits!
            }
        self.variable.isOrContainsClosure = value.isOrContainsClosure
        }

    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var address:ThreeAddress
        if value is ThreeAddress
            {
            address = value as! ThreeAddress
            }
        else
            {
            try value.threeAddress(pass: pass)
            address = pass.lastLHS()
            }
        pass.add(ThreeAddressInstruction(lhs:variable,operand1:address,operation:.assign,operand2:nil))
        }

    public override func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return([variable] + value.touchedStoredValues())
        }
    }
