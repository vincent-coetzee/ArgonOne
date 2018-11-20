//
//  ArgonParameterNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonStackBasedValue
    {
    var offsetFromBP:Int { get }
    var enclosingStackFrame:ArgonStackFrame? { get }
    }

public class ArgonParameterNode:ArgonStoredValueNode,ArgonStackBasedValue
    {
    public var type:ArgonType!
    public var traitsPointer:Pointer?
    public var offsetFromBP:Int = 0

    public override var isMemoryBased:Bool
        {
        return(true)
        }
    
    public override var isStackBased:Bool
        {
        return(true)
        }
        
    public override var isParameter:Bool
        {
        return(true)
        }
    
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
    
    init(name:ArgonName,type:ArgonType)
        {
        self.type = type
        super.init(name:name)
        }
    
    public func asArgonParameter() -> ArgonParameter
        {
        let new = ArgonParameter(fullName: self.name.string)
        new.traits = self.traits.asArgonTraits()
        new.offsetFromBP = self.offsetFromBP
        return(new)
        }
    }

public class ArgonParameterValueNode:ArgonParameterNode
    {
    public private(set) var valueExpression:ArgonExpressionNode
    
    init(name:ArgonName,traits:ArgonTraitsNode,value:ArgonExpressionNode)
        {
        self.valueExpression = value
        super.init(name:name,type:traits)
        }
    }
