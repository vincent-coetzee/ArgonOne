//
//  ArgonImportNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonImportNode:ArgonParseNode
    {
    public var fullName:ArgonName = .null
    public var internalName:ArgonName = .null
    public var externalModuleName:ArgonName?
    public var paths:[String] = []
    public var itemName:ArgonName?
    
    public init(paths:[String])
        {
        self.paths = paths
        super.init()
        }
    
    public override var isImport:Bool
        {
        return(true)
        }
    
    public func asArgonImport() -> ArgonImport
        {
        let new = ArgonImport(fullName:fullName.string,paths:paths)
        new.internalName = internalName.string
        new.externalModuleName = externalModuleName?.string
        new.itemName = itemName?.string
        return(new)
        }
    }
