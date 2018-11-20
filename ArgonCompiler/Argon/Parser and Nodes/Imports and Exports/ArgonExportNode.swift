//
//  ArgonExportNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonExportNode:ArgonParseNode
    {
    public var internalNames:[ArgonName] = []
    public var itemName:ArgonName?
    
    public override var isExport:Bool
        {
        return(true)
        }
    
    public func asArgonExport() -> ArgonExport
        {
        let new = ArgonExport(fullName:internalNames[0].string)
        new.internalNames = internalNames.map{$0.string}
        new.itemName = itemName?.string
        return(new)
        }
    }
