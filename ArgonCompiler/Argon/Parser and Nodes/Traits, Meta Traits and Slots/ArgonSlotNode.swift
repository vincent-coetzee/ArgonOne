//
//  ArgonSlotNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSlotNode:ArgonStoredValueNode
    {
    public var type:ArgonType
    public var initialValue:ArgonExpressionNode?
    public var containingTraits:ArgonTraitsNode?
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(type as! ArgonTraitsNode)
            }
        set
            {
            }
        }
    
    public var hasEmptyTypeTemplate:Bool
        {
        return(false)
        }
    
    public override var isVariable:Bool
        {
        return(false)
        }
    
    public override var isSlot:Bool
        {
        return(true)
        }
    
    init(name:String,type:ArgonType)
        {
        self.type = type
        super.init(name:ArgonName(name))
        }
    }
