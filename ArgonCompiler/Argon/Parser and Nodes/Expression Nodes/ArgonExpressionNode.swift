//
//  ArgonValueNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonExpressionNode:ArgonParseNode,Hashable
    {
    public static func == (lhs: ArgonExpressionNode, rhs: ArgonExpressionNode) -> Bool
        {
        return(lhs.hashValue == rhs.hashValue)
        }
    
    public var containedClosure:ArgonClosureNode?
        {
        return(nil)
        }
    
    private var _locations = ArgonValueLocationList()
    
    private var _hashValue:Int?
    
    public var hashValue:Int
        {
        if _hashValue == nil
            {
            _hashValue = Int.random(in: 0...497645647464)
            }
        return(_hashValue!)
        }
    
    public override var traits:ArgonTraitsNode
        {
        return(ArgonStandardsNode.shared.resolve(name: ArgonName("Void")) as! ArgonTraitsNode)
        }
    
    public var locations:ArgonValueLocationList
        {
        return(_locations)
        }
    
    public func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return([])
        }
    
    public var isCapturedValue:Bool
        {
        return(false)
        }
    
    public var isConstant:Bool
        {
        return(false)
        }
        
    public var isVoidExpression:Bool
        {
        return(true)
        }
    
    public override var isGenericMethod:Bool
        {
        return(false)
        }
    }
