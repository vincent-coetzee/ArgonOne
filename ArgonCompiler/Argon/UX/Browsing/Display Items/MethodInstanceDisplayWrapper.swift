//
//  MethodInstanceDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class MethodInstanceDisplayWrapper:DisplayWrapper
    {
    private let method:ArgonMethodNode
    
    public override var name:String
        {
        return(method.name.string)
        }
    
//    public override var parameterAndTraitsNames:[(String,String)]
//        {
//        return(method.parameters.map {($0.name.string,$0.traits.name.string)})
//        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Method")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.methodInstance)
        }
    
    init(method:ArgonMethodNode)
        {
        self.method = method
        }
    }
