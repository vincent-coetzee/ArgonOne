//
//  ArgonStoredValueNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonDataBasedValue
    {
    var offsetInDataSegment:Int { get set }
    }

public class ArgonStoredValueNode:ArgonExpressionNode,ThreeAddress,ArgonDataBasedValue
    {
    public var enclosingStackFrame:ArgonStackFrame?
    public private(set) var name:ArgonName
    private var _containsClosure:Bool = false
    public var symbolTableEntry:ArgonSymbolTableEntry?
    public var offsetInDataSegment:Int = 0
    
    public func isSame(as address:ThreeAddress) -> Bool
        {
        if type(of: address) == type(of: self)
            {
            return(address as! ArgonStoredValueNode == self)
            }
        return(false)
        }
    
    public var containsClosure:Bool
        {
        return(false)
        }
    
    public override var hashValue:Int
        {
        return(symbolTableEntry!.name.hashValue)
        }
    
    public var isMemoryBased:Bool
        {
        return(false)
        }
    
    public var isParameter:Bool
        {
        return(false)
        }
    
    public override var isLocal:Bool
        {
        return(false)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isStackBased:Bool
        {
        return(false)
        }
    
    public override var isStoredValue:Bool
        {
        return(true)
        }
    
    public var isVariable:Bool
        {
        return(false)
        }
        
    public var isReadOnly:Bool
        {
        return(false)
        }
    
    public override var isOrContainsClosure:Bool
        {
        get
            {
            return(_containsClosure)
            }
        set
            {
            _containsClosure = newValue
            }
        }
    
    public override var isObject:Bool
        {
        return(true)
        }
    
    init(name:ArgonName)
        {
        self.name = name
        super.init()
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
//        pass.add(ThreeAddressInstruction(lhs: pass.newTemporary(),operation: .assign,operand1: self))
        }
    }
