//
//  ArgonTypeTemplateInstanceNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonTypeTemplateInstanceNode:ArgonTypeTemplateNode
    {
    public var instantiatedType:ArgonType?
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(instantiatedType?.traits ?? ArgonStandardsNode.shared.voidTraits)
            }
        set
            {
            }
        }
    
    public override var isHollowTemplateType:Bool
        {
        return(false)
        }
    
    public override var isTypeTemplateInstance:Bool
        {
        return(true)
        }
    
   public override var isTypeTemplate:Bool
        {
        return(false)
        }
    }
