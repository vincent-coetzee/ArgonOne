//
//  ArgonTypeTemplateNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonTypeTemplateNode:ArgonParseNode,ArgonType
    {
    public var name: ArgonName
    private var _traits:ArgonTraitsNode!
    public var definingTraits:ArgonTraitsNode?
    
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
    
    public var isTemplateType:Bool
        {
        return(true)
        }
    
    public override var isTemplateVariable:Bool
        {
        return(true)
        }
    
    public var isHollowTemplateType:Bool
        {
        return(true)
        }
    
    init(name:ArgonName)
        {
        self.name = name
        }
    
    public func asArgonTypeTemplate() -> ArgonTypeTemplate
        {
        let new = ArgonTypeTemplate(name: name.string)
        new.traits = _traits == nil ? ArgonRelocationTable.shared.traits(at: "Argon::Void")! : _traits.asArgonTraits()
        new.definingTraits = definingTraits?.name.string ?? "Argon::Void"
        return(new)
        }
    
    public func makeInstance(with type:ArgonType) -> ArgonTypeTemplateInstanceNode
        {
        let new = ArgonTypeTemplateInstanceNode(name: name)
        new.definingTraits = definingTraits
        new.instantiatedType = type
        return(new)
        }
    
   public override var isTypeTemplate:Bool
        {
        return(true)
        }
    }
