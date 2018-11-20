//
//  ArgonParseContainerNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonScopeNode:ArgonNamedNode
    {
    public var containingScope:ArgonParseScope?
    public var nodes:[ArgonParseNode] = []
    public var keyedTypes:[ArgonName:ArgonParseNode] = [:]
    public var locals:[ArgonLocalVariableNode] = []
    
    public func add(node:ArgonParseNode)
        {
        nodes.append(node)
        if node.isType
            {
            if node is ArgonNamedNode
                {
                keyedTypes[(node as! ArgonNamedNode).name] = node
                }
            else if node is ArgonTraitsNode
                {
                keyedTypes[(node as! ArgonTraitsNode).name] = node
                }
            else if node is ArgonMethodNode
                {
                keyedTypes[(node as! ArgonMethodNode).name] = node
                }
            }
        }
    
    public func add(variable:ArgonVariableNode)
        {
        guard let local = variable as? ArgonLocalVariableNode else
            {
            fatalError("Only locals can be added here")
            }
        locals.append(local)
        }
    }
