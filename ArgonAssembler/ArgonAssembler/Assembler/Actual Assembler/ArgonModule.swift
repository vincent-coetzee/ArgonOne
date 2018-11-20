//
//  ArgonModule.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonModule
    {
    public private(set) var name:String
    public private(set) var imports:[String:ArgonImport] = [:]
    public private(set) var moduleName:String
    
    init(module:String,name:String)
        {
        self.moduleName = module
        self.name = name
        }
    }
