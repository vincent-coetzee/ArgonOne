//
//  ArgonMacroNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonPolymorphicArgument:ArgonParseNode
    {
    public private(set) var name:ArgonName
    
    public override var traits:ArgonTraitsNode
        {
        return(ArgonStandardsNode.shared!.polymorphicArgumentTraits)
        }
    
    public init(name:ArgonName)
        {
        self.name = name
        }
    }

public class ArgonMacroNode:ArgonCompoundMethodStatementNode
    {
    public private(set) var fullName:ArgonName
    public private(set) var name:ArgonName
    public var polymorphicArguments:[ArgonPolymorphicArgument] = []
    
    public init(containingScope:ArgonParseScope,fullName:ArgonName)
        {
        self.fullName = fullName
        self.name = ArgonName(fullName.last)
        super.init(containingScope:containingScope)
        }
    }
