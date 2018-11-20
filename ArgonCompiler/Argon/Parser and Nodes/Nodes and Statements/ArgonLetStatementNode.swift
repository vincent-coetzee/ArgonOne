//
//  ArgonTemporaryVariableAssignmentNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//
//
//import Foundation
//
public class ArgonLetStatementNode:ArgonMethodStatementNode
    {
    public private(set) var name:ArgonName
    public private(set) var type:ArgonType?
    public private(set) var value:ArgonExpressionNode
    public private(set) var local:ArgonLocalVariableNode
    
    init(name:String,type:ArgonType?,value:ArgonExpressionNode,local:ArgonLocalVariableNode)
        {
        self.name = ArgonName(name)
        self.type = type
        self.value = value
        self.local = local
        if type == nil
            {
            local.traits = value.traits
            }
        self.local.isOrContainsClosure = value.isOrContainsClosure
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
        pass.add(ThreeAddressInstruction(lhs:local,operand1:address,operation:.assign,operand2:nil))
        }
    
    public override func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return([local] + value.touchedStoredValues())
        }
    }
