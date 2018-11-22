//
//  ArgonStringValueNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonConstantValue
    {
    var traits:ArgonTraitsNode { get }
    var integerValue:Int { get }
    var floatingPointValue:Float { get }
    var stringValue:String { get }
    var symbolValue:String { get }
    var booleanValue:Bool { get }
    }

public class ArgonConstantNode:ArgonExpressionNode,ThreeAddress,ArgonConstantValue
    {
    public static var nameCounter = 1
    
    public private(set) var literalString:String?
    public private(set) var literalSymbol:String?
    public private(set) var literalInteger:Int?
    public private(set) var literalFloat:Float?
    public private(set) var literalBoolean:Bool?
    public private(set) var machineLiteral:UInt64?
    
    internal var _name:ArgonName?
    
    private var _traits:ArgonTraitsNode
    
    public var stringValue:String
        {
        return(literalString!)
        }
    
    public var integerValue:Int
        {
        return(literalInteger!)
        }
    
    public var floatingPointValue:Float
        {
        return(literalFloat!)
        }

    public var symbolValue:String
        {
        return(literalSymbol!)
        }
    
    public var booleanValue:Bool
        {
        return(literalBoolean!)
        }
    
    public var name:ArgonName
        {
        if _name != nil
            {
            return(_name!)
            }
        var string:String = ""
        if _traits == ArgonStandardsNode.shared.integerTraits
            {
            string = "Integer(\(literalInteger!))"
            }
        else if _traits == ArgonStandardsNode.shared.floatTraits
            {
            string = "Float(\(literalFloat!))"
            }
        else if _traits == ArgonStandardsNode.shared.booleanTraits
            {
            string = "Boolean(\(literalBoolean!))"
            }
        else if _traits == ArgonStandardsNode.shared.symbolTraits
            {
            string = "Symbol(\(literalSymbol!))"
            }
        else if _traits == ArgonStandardsNode.shared.stringTraits
            {
            string = "String(\(literalString!))"
            }
        else
            {
            string = "Error(Traits could not be indentified)"
            }
        _name = ArgonName(string)
        return(_name!)
        }
    
    public func isSame(as address:ThreeAddress) -> Bool
        {
        if type(of: address) == type(of: self)
            {
            return(address as! ArgonConstantNode == self)
            }
        return(false)
        }
    
    public override var traits:ArgonTraitsNode
        {
        return(_traits)
        }
    
    public var isVariable:Bool
        {
        return(false)
        }
    
    public var isInteger:Bool
        {
        return(false)
        }
    
    public var isStackBased:Bool
        {
        return(false)
        }
    
    public var isTemporary:Bool
        {
        return(false)
        }
    
    public var isParameter:Bool
        {
        return(false)
        }
    
    public override var isConstant:Bool
        {
        return(true)
        }
        
    public override var isVoidExpression:Bool
        {
        return(traits == ArgonStandardsNode.shared.voidTraits)
        }
    
    init(string:String)
        {
        self.literalString = string
        _traits = ArgonStandardsNode.shared.stringTraits
        super.init()
        }
        
   init(symbol:String)
        {
        self.literalSymbol = symbol
        _traits = ArgonStandardsNode.shared.symbolTraits
        super.init()
        }
    
    init(float:Float)
        {
        self.literalFloat = float
        _traits = ArgonStandardsNode.shared.floatTraits
        super.init()
        }
    
    init(boolean:Bool)
        {
        self.literalBoolean = boolean
        _traits = ArgonStandardsNode.shared.booleanTraits
        super.init()
        }
    
    init(integer:Int)
        {
        self.literalInteger = integer
        _traits = ArgonStandardsNode.shared.integerTraits
        super.init()
        }
    
    init(void:Bool)
        {
        _traits = ArgonStandardsNode.shared.voidTraits
        super.init()
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        pass.add(ThreeAddressInstruction(lhs: pass.newTemporary(),operation: .assign,operand1: self))
        }
    }
