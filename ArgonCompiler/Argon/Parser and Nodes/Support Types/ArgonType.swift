//
//  ArgonType.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonType
    {
    var name:ArgonName { get }
    var isTraits:Bool { get }
    var isTypeTemplate:Bool { get }
    var isValidSlotType:Bool { get }
    var traits:ArgonTraitsNode { get }
    var isTemplateType:Bool { get }
    var isHollowTemplateType:Bool { get }
    }

extension ArgonType
    {
    public var isTemplateType:Bool
        {
        return(false)
        }
    
    public var isHollowTemplateType:Bool
        {
        return(true)
        }
    }
