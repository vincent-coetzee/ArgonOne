//
//  ArgonArithmeticExpression.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/15.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum Operation
    {
    case add
    case sub
    case mul
    case div
    case mod
    case and
    case or
    case not
    case xor
    
    var threeAddressOperation:ThreeAddressOperation
        {
        switch(self)
            {
            case .add:
                return(.add)
            case .sub:
                return(.sub)
            case .mul:
                return(.mul)
            case .div:
                return(.div)
            case .and:
                return(.and)
            case .or:
                return(.or)
            case .not:
                return(.not)
            case .xor:
                return(.xor)
            case .mod:
                return(.mod)
            }
        }
    }

public class ArgonArithmeticExpressionNode:ArgonExpressionNode
    {
    public private(set) var lhs:ArgonExpressionNode
    public private(set) var rhs:ArgonExpressionNode
    public private(set) var operation:TokenType
    
    public override var traits:ArgonTraitsNode
        {
        if lhs.traits == rhs.traits
            {
            return(lhs.traits)
            }
        return(ArgonStandardsNode.shared.resolve(name: ArgonName("Error")) as! ArgonTraitsNode)
        }
    
    public override var isVoidExpression:Bool
        {
        return(false)
        }
    
    public override func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return(lhs.touchedStoredValues()+rhs.touchedStoredValues())
        }
    
    init(_ lhs:ArgonExpressionNode,_ operation:TokenType,_ rhs:ArgonExpressionNode)
        {
        self.lhs = lhs
        self.operation = operation
        self.rhs = rhs
        super.init()
        }

    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        var address1:ThreeAddress
        if lhs is ThreeAddress
            {
            address1 = lhs as! ThreeAddress
            }
        else
            {
            try lhs.threeAddress(pass: pass)
            address1 = pass.lastLHS()
            }
        var address2:ThreeAddress
        if rhs is ThreeAddress
            {
            address2 = rhs as! ThreeAddress
            }
        else
            {
            try rhs.threeAddress(pass: pass)
            address2 = pass.lastLHS()
            }
        var threeAddressOperation:ThreeAddressOperation
        switch(operation)
            {
            case .plus:
                threeAddressOperation = .add
            case .minus:
                threeAddressOperation = .sub
            case .mul:
                threeAddressOperation = .mul
            case .div:
                threeAddressOperation = .div
            case .mod:
                threeAddressOperation = .mod
            default:
                threeAddressOperation = .none
            }
        pass.add(ThreeAddressInstruction(lhs:pass.newTemporary(),operand1: address1,operation:threeAddressOperation,operand2:address2))
        }
    }

