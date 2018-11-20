//
//  ArgonCapturedValue.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/08.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonCapturedValue:ArgonExpressionNode,ThreeAddress
    {
    public func isSame(as other: ThreeAddress) -> Bool
        {
        if type(of: self) != type(of: other)
            {
            return(false)
            }
        let otherValue = other as! ArgonCapturedValue
        if otherValue.name != self.name
            {
            return(false)
            }
        return(true)
        }
    
    public private(set) var name:ArgonName = ArgonName()
    private var _traits = ArgonStandardsNode.shared.voidTraits
    public var offsetFromBP:Int = 0
    public var originalValue:ArgonExpressionNode
    
    public override var isCapturedValue:Bool
        {
        return(true)
        }
    
    public var isVariable: Bool
        {
        return(false)
        }
    
    public var isParameter: Bool
        {
        return(false)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isStackBased: Bool
        {
        return(true)
        }
    
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
   
    init(name:ArgonName,traits:ArgonTraitsNode,original:ArgonExpressionNode)
        {
        self.name = name
        self._traits = traits
        self.originalValue = original
        super.init()
        }
    }
