//
//  ArgonGlobalVariableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/10.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonGlobalVariableNode:ArgonVariableNode,ArgonRelocatable
    {
    private var initialValue:ArgonExpressionNode?
    public private(set) var id:Int = 0
    
    public init(name:ArgonName,traits:ArgonTraitsNode,initialValue:ArgonExpressionNode?)
        {
        self.id = Argon.nextCounter
        self.initialValue = initialValue
        super.init(name:name,traits:traits)
        }
    
    public func asArgonGlobal() -> ArgonGlobal
        {
        let new = ArgonGlobal(fullName:self.name.string,traits:self.traits.asArgonTraits())
        new.id = self.id
        return(new)
        }
    
    public override var isGlobal:Bool
        {
        return(true)
        }
    }
