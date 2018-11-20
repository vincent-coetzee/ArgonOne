//
//  ParserNode.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ParserNode
    {
    var line:Int { get }
    var label:String? { get }
    }

