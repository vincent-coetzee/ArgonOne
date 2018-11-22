//
//  ArgonRegisterVariableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonRegisterVariableNode:ArgonVariableNode
    {
    public private(set) var register:MachineRegister
    
    public init(name:ArgonName,traits:ArgonTraitsNode,register:MachineRegister)
        {
        self.register = register
        super.init(name:name,traits:traits)
        }
    }
