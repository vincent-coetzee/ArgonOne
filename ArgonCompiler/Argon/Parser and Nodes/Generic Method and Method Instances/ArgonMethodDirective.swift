//
//  MethodDirective.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ArgonMethodDirective:OptionSet
    {
    public let rawValue:Int
    
    static let inline = ArgonMethodDirective(rawValue: 1)
    static let dynamic = ArgonMethodDirective(rawValue: 2)
    static let system = ArgonMethodDirective(rawValue: 4)
    static let `static` = ArgonMethodDirective(rawValue: 8)
    
    public init(rawValue:Int)
        {
        self.rawValue = rawValue
        }
    }
