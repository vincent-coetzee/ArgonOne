//
//  ArgonVariableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonVariableNode:ArgonStoredValueNode
    {
    public var scopedName:ArgonName = ArgonName("")
    private var _readOnly:Bool = false
    internal var _traits:ArgonTraitsNode?
    
    public override var isVariable:Bool
        {
        return(true)
        }
    
    public override var isMemoryBased:Bool
        {
        return(true)
        }
    
    public override var isStackBased:Bool
        {
        return(false)
        }
    
    public override var isReadOnly:Bool
        {
        get
            {
            return(_readOnly)
            }
        set
            {
            _readOnly = newValue
            }
        }
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(_traits!)
            }
        set
            {
            _traits = newValue
            }
        }
    
    init(name:ArgonName,traits:ArgonTraitsNode)
        {
        _traits = traits
        super.init(name:name)
        }
    }


