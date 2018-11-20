//
//  ListDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ListDisplayWrapper:DisplayWrapper
    {
    private var list = DisplayItemList()
    private let _name:String
    
    public override var name:String
        {
        return(_name)
        }
    
    public override var children:DisplayItemList
        {
        return(list)
        }
    
    init(name:String,list:DisplayItemList)
        {
        self.list = list
        self._name = name
        super.init()
        }
    }
