//
//  ArgonThisNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonThisNode:ArgonExpressionNode
    {
    private var _traits:ArgonTraitsNode
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(_traits)
            }
        set
            {
            _traits = newValue
            }
        }
        
    init(traits:ArgonTraitsNode)
        {
        _traits = traits
        }
    }
