//
//  SourceLocation.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct SourceLocation:Codable
    {
    let lineNumber:Int
    let tokenStart:Int
    let tokenStop:Int
    let lineStart:Int
    let lineStop:Int
    
    init(line:Int = 0,tokenStart:Int = 0,tokenStop:Int = 0,lineStart:Int = 0,lineStop:Int = 0)
        {
        self.lineNumber = line
        self.tokenStart = tokenStart
        self.tokenStop = tokenStop
        self.lineStart = lineStart
        self.lineStop = lineStop
        }
    }
