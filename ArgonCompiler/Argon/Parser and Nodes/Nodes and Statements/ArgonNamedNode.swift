//
//  ArgonNamedParseNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonNamedNode:ArgonParseNode
    {
    public private(set) var name:ArgonName
    
    init(name:String)
        {
        self.name = ArgonName(name)
        super.init()
        }
    
    init(name:ArgonName)
        {
        self.name = name
        super.init()
        }
    }
