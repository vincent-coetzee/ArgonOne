//
//  ArgonCaseStatementNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonCaseStatementNode:ArgonCompoundMethodStatementNode
    {
    public var caseExpression:ArgonExpressionNode
    
    init(containingScope:ArgonParseScope,expression:ArgonExpressionNode)
        {
        caseExpression = expression
        super.init(containingScope: containingScope)
        }
    }
