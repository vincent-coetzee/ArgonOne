//
//  NamedConstantDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class NamedConstantDisplayWrapper:DisplayWrapper
    {
    private let constant:ArgonNamedConstantNode
    
    public override var name:String
        {
        return(constant.name.string)
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Constant")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.constant)
        }
    
    init(constant:ArgonNamedConstantNode)
        {
        self.constant = constant
        }
    }
