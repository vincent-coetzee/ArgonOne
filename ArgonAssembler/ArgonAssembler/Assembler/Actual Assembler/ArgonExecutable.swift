//
//  ArgonExecutable.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonExecutable:ArgonModule
    {
    public private(set) var entryIP:Int

    init(module:String,name:String,entryIP:Int)
        {
        self.entryIP = entryIP
        super.init(module:module,name:name)
        }
    }
