//
//  LocalDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class LocalDisplayWrapper:DisplayWrapper
    {
    private let local:ArgonLocalVariableNode
    
    public override var name:String
        {
        return(local.name.string)
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Local")!)
        }
        
    public override var contentType:DisplayCellContentType
        {
        return(.local)
        }
    
    init(local:ArgonLocalVariableNode)
        {
        self.local = local
        }
    }
