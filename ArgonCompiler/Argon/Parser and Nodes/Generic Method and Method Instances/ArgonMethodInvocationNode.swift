//
//  ArgonMethodInvocationNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonMethodValueNode:ArgonExpressionNode
    {
    public private(set) var arguments:[ArgonParameterValueNode]
    public var isResolved:Bool = false
    public private(set) var method:ArgonGenericMethodNode
    public var lineTrace:ArgonLineTrace?
    
    public override var traits:ArgonTraitsNode
        {
        return(method.returnType.traits)
        }
        
    init(genericMethod:ArgonGenericMethodNode,arguments:[ArgonParameterValueNode])
        {
        self.method = genericMethod
        self.arguments = arguments
        super.init()
        }

    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        for argument in arguments.reversed()
            {
            if argument.valueExpression is ThreeAddress
                {
                pass.add(ThreeAddressInstruction(operation: .param,operand1: argument.valueExpression as! ThreeAddress))
                }
            else
                {
                try argument.valueExpression.threeAddress(pass:pass)
                pass.add(ThreeAddressInstruction(operation: .param,operand1: pass.lastLHS()))
                }
            }
        pass.add((ThreeAddressInstruction(lhs: pass.newTemporary(),operand1: method,operation: .dispatch,operand2: arguments.count)))
        }
    }

public class ArgonMethodInvocationNode:ArgonMethodStatementNode
    {
    public private(set) var arguments:[ArgonParameterValueNode]
    public var isResolved:Bool = false
    public private(set) var method:ArgonGenericMethodNode
    
    init(genericMethod:ArgonGenericMethodNode,arguments:[ArgonParameterValueNode])
        {
        self.method = genericMethod
        self.arguments = arguments
        super.init()
        }
    
    public override func touchedStoredValues() -> [ArgonStoredValueNode]
        {
        return(arguments.flatMap {$0.touchedStoredValues()})
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        for argument in arguments.reversed()
            {
            if argument.valueExpression is ThreeAddress
                {
                pass.add(ThreeAddressInstruction(operation: .param,operand1: argument.valueExpression as! ThreeAddress))
                }
            else
                {
                try argument.valueExpression.threeAddress(pass:pass)
                pass.add(ThreeAddressInstruction(operation: .param,operand1: pass.lastLHS()))
                }
            }
        pass.add((ThreeAddressInstruction(lhs: pass.newTemporary(),operand1: method,operation: .dispatch,operand2: arguments.count)))
        }
    }

public class ArgonMethodInvocationExpressionNode:ArgonExpressionNode
    {
    private var invocation:ArgonMethodInvocationNode
    
    init(invocation:ArgonMethodInvocationNode)
        {
        self.invocation = invocation
        }
    }
