//
//  GenericMethodDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class GenericMethodDisplayWrapper:DisplayWrapper
    {
    private let method:ArgonGenericMethodNode
    private var list = DisplayItemList()
    
    public override var name:String
        {
        return(method.name.string)
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"GenericMethod")!)
        }
    
    public override var children:DisplayItemList
        {
        guard list.isEmpty else
            {
            return(list)
            }
        list = DisplayItemList(items: method.instances.map {MethodInstanceDisplayWrapper(method: $0)})
        return(list)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.genericMethod)
        }
    
    init(method:ArgonGenericMethodNode)
        {
        self.method = method
        }
    }
