//
//  ArgonLocalVariableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonLocalVariableNode:ArgonVariableNode,ArgonStackBasedValue
    {    
    public var offsetFromBP:Int = 0
    public var stackFrameDepth:Int = 0
    public var initialValue:ArgonExpressionNode?
    
    public override var isStackBased:Bool
        {
        return(true)
        }
        
    public override var isLocal:Bool
        {
        return(true)
        }
    
    public init(name:ArgonName,traits:ArgonTraitsNode,initialValue:ArgonExpressionNode?)
        {
        self.initialValue = initialValue
        super.init(name:name,traits:traits)
        }
    
    public override init(name:ArgonName,traits:ArgonTraitsNode)
        {
        super.init(name:name,traits:traits)
        }
    
    public func asArgonLocalVariable() -> ArgonLocalVariable
        {
        let new = ArgonLocalVariable(fullName: self.name.string)
        new.traits = self.traits.asArgonTraits()
        return(new)
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        guard let value = initialValue else
            {
            return
            }
        try value.threeAddress(pass: pass)
        let lhs = pass.lastLHS()
        pass.add(ThreeAddressInstruction(lhs: self,operation: .assign,operand1: lhs))
        }
    }
