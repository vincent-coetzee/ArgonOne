//
//  ImportExportDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

fileprivate enum ItemHolder
    {
    case `import`(ArgonImportNode)
    case export(ArgonExportNode)
    
//    public var name:String
//        {
//        switch(self)
//            {
//            case .import(let item):
//                return(item.name.string)
//            case .export(let item):
//                return(item.name.string)
//            }
//        }
    }

public class ImportExportDisplayWrapper:DisplayWrapper
    {
    private let item:ItemHolder
    
    public override var name:String
        {
        return("")
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Compile")!)
        }

    public override var contentType:DisplayCellContentType
        {
        if case ItemHolder.import(_) = item
            {
            return(.import)
            }
        else
            {
            return(.export)
            }
        }
    
    init(import item:ArgonImportNode)
        {
        self.item = .import(item)
        }
    
    init(export item:ArgonExportNode)
        {
        self.item = .export(item)
        }
    }
