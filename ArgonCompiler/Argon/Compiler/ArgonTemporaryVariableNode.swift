//
//  ArgonTemporaryVariable.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonMemoryBasedValue
    {
    var address:ArgonWord { get }
    }

public class ArgonTemporaryVariableNode:ArgonStoredValueNode,ArgonMemoryBasedValue
    {
    public var address:ArgonWord = 0
    
    public override var isTemporary: Bool
        {
        return(true)
        }
    
    public override var hashValue:Int
        {
        return(self.name.string.hashValue)
        }
    
    public override var isVariable:Bool
        {
        return(false)
        }
    }
