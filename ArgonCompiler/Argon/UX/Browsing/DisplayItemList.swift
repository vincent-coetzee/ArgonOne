//
//  DisplayItemList.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public struct DisplayItemList:Collection
    {
    private var items:[DisplayItem] = []
    
    public var isEmpty:Bool
        {
        return(items.isEmpty)
        }
    
    public var count:Int
        {
        return(items.count)
        }
    
    public var startIndex:Int
        {
        return(items.startIndex)
        }
    
    public var endIndex:Int
        {
        return(items.endIndex)
        }
    
    public init(parent:DisplayItem)
        {
        for item in parent.children
            {
            self.append(item)
            }
        }
    
    public init(items:[DisplayItem])
        {
        self.items = items
        }
    
    public init()
        {
        }
    
    public mutating func append(_ item:DisplayItem)
        {
        items.append(item)
        }
    
    public func index(after index:Int) -> Int
        {
        return(items.index(after: index))
        }
    
    public subscript(_ index:Int) -> DisplayItem
        {
        return(items[index])
        }
    
    public func maximumWidthOfNames(font:NSFont) -> CGFloat
        {
        let attributes:[NSAttributedString.Key:Any] = [.font:font]
        var maxWidth:CGFloat = 0
        for item in items
            {
            maxWidth = Swift.max(maxWidth,NSAttributedString(string: item.name,attributes: attributes).size().width)
            }
        return(maxWidth)
        }
    }
