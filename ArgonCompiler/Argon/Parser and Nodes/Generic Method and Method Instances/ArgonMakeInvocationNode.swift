//
//  ArgonMakeValueNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonMakeInvocationNode:ArgonExpressionNode
    {
    private let _traits:ArgonTraitsNode
    private var traitsNamePointer:Pointer?
    private var arguments:[ArgonExpressionNode] = []
    
    init(traits:ArgonTraitsNode)
        {
        self._traits = traits
        arguments.append(traits)
        super.init()
        }
    
    init(arguments:[ArgonExpressionNode])
        {
        self._traits = arguments[0] as! ArgonTraitsNode
        self.arguments = arguments
        super.init()
        }
    
    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        for argument in arguments.reversed()
            {
            if argument is ThreeAddress
                {
                pass.add(ThreeAddressInstruction(operation: .param,operand1: argument as! ThreeAddress))
                }
            else
                {
                try argument.threeAddress(pass: pass)
                pass.add(ThreeAddressInstruction(operation: .param,operand1: pass.lastLHS()))
                }
            }
        pass.add(ThreeAddressInstruction(lhs:pass.newTemporary(),operand1: ArgonMethodNode(name: ArgonName("make")),operation: .make,operand2: arguments.count))
        }
    
    public override var traits:ArgonTraitsNode
        {
        get
            {
            return(_traits)
            }
        set
            {
            }
        }
    }
