//
//  ArgonWithStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonWithStatementNode:ArgonCompoundMethodStatementNode
    {
    public private(set) var targetExpression:ArgonExpressionNode
    private let withTraits:ArgonTraitsNode
    
    public var instanceExpression:ArgonExpressionNode
        {
        return(targetExpression)
        }
    
    init(containingScope:ArgonParseScope,target:ArgonExpressionNode)
        {
        self.targetExpression = target
        withTraits = target.traits
        super.init(containingScope:containingScope)
        }
    
    public override func resolve(name:ArgonName) -> ArgonParseNode?
        {
        if let node = withTraits.resolve(name: name)
            {
            return(node)
            }
        return(super.resolve(name: name))
        }
    
    public override func enclosingWith() -> ArgonWithStatementNode?
        {
        return(self)
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        pass.add(ThreeAddressInstruction(operation: .enter,operand1: self.locals.count * 8))
        try statements.threeAddress(pass: pass)
        pass.add(ThreeAddressInstruction(operation: .leave,operand1: self.locals.count * 8))
        }
    }
