//
//  ArgonSignalStatement.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSignalStatementNode:ArgonMethodStatementNode
    {
    public private(set) var symbolExpression:ArgonExpressionNode
    
    public init(symbol:ArgonExpressionNode)
        {
        self.symbolExpression = symbol
        super.init()
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var address:ThreeAddress
        if symbolExpression is ThreeAddress
            {
            address = symbolExpression as! ThreeAddress
            }
        else
            {
            try symbolExpression.threeAddress(pass: pass)
            address = pass.lastLHS()
            }
        pass.add(ThreeAddressInstruction(operation: .signal,operand1: address))
        }
    }

