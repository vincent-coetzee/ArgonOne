//
//  ArgonClosureVariableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonClosureVariableNode:ArgonLocalVariableNode
    {
    public private(set) var closure:ArgonClosureNode
    
    public override var containsClosure:Bool
        {
        return(true)
        }
    
    init(name:ArgonName,closure:ArgonClosureNode)
        {
        self.closure = closure
        super.init(name:name,traits: ArgonStandardsNode.shared.closureTraits,initialValue:closure)
        }
    }
