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
    public private(set) var symbol:Symbol
    
    public init(symbol:Symbol)
        {
        self.symbol = symbol
        super.init()
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        pass.add(ThreeAddressInstruction(operation: .signal,operand1: symbol))
        }
    }

