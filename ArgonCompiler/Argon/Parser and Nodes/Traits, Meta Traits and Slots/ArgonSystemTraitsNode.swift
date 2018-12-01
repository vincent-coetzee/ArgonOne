//
//  ArgonSystemTraitsNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSystemTraitsNode:ArgonTraitsNode
    {
    public override var isSystemTraits:Bool
        {
        return(false)
        }
        
    public override var isTraits: Bool
        {
        return(true)
        }
    
    public override var isTypeTemplate: Bool
        {
        return(false)
        }
    }
