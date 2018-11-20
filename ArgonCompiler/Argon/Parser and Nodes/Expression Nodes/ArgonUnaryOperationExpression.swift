//
//  ArgonUnaryOperationExpression.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonUnaryOperationExpression:ArgonExpressionNode
    {
    public private(set) var operation:TokenType
    public private(set) var expression:ArgonExpressionNode

    public override var traits:ArgonTraitsNode
        {
        if operation == .not
            {
            return(ArgonStandardsNode.shared.booleanTraits)
            }
        return(ArgonStandardsNode.shared.errorTraits)
        }
    
    init(operation:TokenType,expression:ArgonExpressionNode)
        {
        self.operation = operation
        self.expression = expression
        super.init()
        }
    
    public override func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return(expression.touchedStoredValues())
        }
    }
