//
//  VMInstructionMode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum VMInstructionMode:Int
    {
    case regular
    case double
    case address
    case leftIndirect
    case rightIndirect
    case immediate
    case register
    case indirect
    }
