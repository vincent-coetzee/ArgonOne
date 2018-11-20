//
//  ArgonTraitsTraitsNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonMetaTraitsNode:ArgonTraitsNode
    {
    public private(set) var instanceTraits:ArgonTraitsNode
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(self)
            }
        set
            {
            }
        }
        
    init(fullName:ArgonName,instanceTraits:ArgonTraitsNode)
        {
        self.instanceTraits = instanceTraits
        super.init(fullName:fullName)
        }
    }
