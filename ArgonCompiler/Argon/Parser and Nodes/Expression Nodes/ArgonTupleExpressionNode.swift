//
//  ArgonTupleExpressionNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonTupleExpressionNode:ArgonExpressionNode
    {
    public private(set) var terms:[ArgonExpressionNode]
    
    init(terms: [ArgonExpressionNode])
        {
        self.terms = terms
        super.init()
        }
    }
