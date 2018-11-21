//
//  ArgonTree.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

fileprivate class SymbolTreeNode
    {
    var key:String
    var left:SymbolTreeNode?
    var right:SymbolTreeNode?
    var pointer:Pointer = wordAsPointer(0)
    
    init(key:String)
        {
        self.key = key
        }
    
    func add(string:String)
        {
        if string < self.key
            {
            if left == nil
                {
                left = SymbolTreeNode(key:string)
                return
                }
            else
                {
                left?.add(string:string)
                }
            }
        }
    }

public class ArgonSymbolTree:ArgonModuleItem
    {
    public var externalName:ArgonName = "Tree"
    public var pointer:Pointer = wordAsPointer(0)
    public var kind:ArgonModuleItemKind = .tree
    fileprivate var root:SymbolTreeNode?
    
    public func add(string:String)
        {
        if root == nil
            {
            root = SymbolTreeNode(key:string)
            }
        else
            {
            root?.add(string:string)
            }
        }
    }
