//
//  ArgonModuleEntry.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonRelocatable
    {
    var id:Int { get }
    }

extension String
    {
    public func asArgonString() -> ArgonString
        {
        return(ArgonString(string:self))
        }
    }
