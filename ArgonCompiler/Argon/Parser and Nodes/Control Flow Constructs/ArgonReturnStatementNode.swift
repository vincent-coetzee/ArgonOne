//
//  ArgonReturnStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonReturnStatementNode:ArgonMethodStatementNode
    {
    public private(set) var returnValue:ArgonExpressionNode
    
    public override var isReturnStatement:Bool
        {
        return(true)
        }
    
    public override var traits:ArgonTraitsNode
        {
        return(returnValue.traits)
        }
    
    init(returnValue:ArgonExpressionNode)
        {
        self.returnValue = returnValue
        }

    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        var address:ThreeAddress
        pass.addLineTraceToNextStatement(lineTrace: self.lineTrace!)
        if returnValue is ThreeAddress
            {
            address = returnValue as! ThreeAddress
            }
        else
            {
            try returnValue.threeAddress(pass: pass)
            address = pass.lastLHS()
            }
        pass.add(ThreeAddressInstruction(operation: .return,operand1: address))
        }
    }
