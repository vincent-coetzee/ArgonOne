//
//  ArgonImport.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonImport
    {
    public private(set) var internalName:String
    public private(set) var externalName:String
    public private(set) var content:Any
    public private(set) var contentType:ArgonImportContentType
    
    init(internal internalName:String,external:String,content:Any,type:ArgonImportContentType)
        {
        self.internalName = internalName
        self.externalName = external
        self.content = content
        self.contentType = type
        }
    }
