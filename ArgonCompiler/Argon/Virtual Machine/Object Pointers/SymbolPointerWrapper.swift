//
//  SymbolPointerWrapper.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class SymbolPointerWrapper:StringPointerWrapper
    {
    public var symbol:String
        {
        get
            {
            return(self.string)
            }
        set
            {
            self.string = newValue
            }
        }
    }
