//
//  EntryPointDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class EntryPointDisplayWrapper:DisplayWrapper
    {
    private let point:ArgonEntryPointNode
    
    public override var name:String
        {
        return("entryPoint")
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"EntryPoint")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.entryPoint)
        }
    
    init(point:ArgonEntryPointNode)
        {
        self.point = point
        }
    }
