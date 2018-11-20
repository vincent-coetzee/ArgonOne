//
//  DisplayItem.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public enum DisplayCellContentType
    {
    case `default`
    case genericMethod
    case methodInstance
    case slot
    case traits
    case entryPoint
    case `import`
    case export
    case local
    case executable
    case library
    case constant
    }

public protocol DisplayItem
    {
    var key:Int { get }
    var name:String { get }
    var icon:NSImage { get }
    var children:DisplayItemList { get }
    var childCount:Int { get }
    var iconImage:NSImage { get }
    var contentType:DisplayCellContentType { get }
    static func configureColumns(in:NSTableView,list:DisplayItemList)
    func render(column:NSTableColumn) -> NSView?
    var nakedItem:Any? { get }
    }

extension DisplayItem
    {
    public var childCount:Int
        {
        return(self.children.count)
        }
    
    public var iconImage:NSImage
        {
        let anIcon = self.icon
        anIcon.size = NSSize(width: 20,height: 20)
        return(anIcon)
        }
    }
