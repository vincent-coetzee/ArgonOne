//
//  Column.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public protocol ColumnView
    {
    func set(width:CGFloat)
    }

public class Column
    {
    private var views:[NSView & ColumnView] = []
    private var maximumWidth:CGFloat = 0
    
    public func add(view:NSView & ColumnView,in width:CGFloat)
        {
        let oldMaximumWidth = maximumWidth
        maximumWidth = max(maximumWidth,width)
        if maximumWidth != oldMaximumWidth
            {
            for view in views
                {
                view.set(width: maximumWidth)
                }
            }
        }
    }
