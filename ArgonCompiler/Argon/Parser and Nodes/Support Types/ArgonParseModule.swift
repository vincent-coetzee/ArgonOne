//
//  ArgonModule.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonParseModule
    {
    static var current:ArgonParseModule! { get }
    var moduleName:ArgonName { get }
    func allMethods() -> [ArgonMethodNode]
    func allLocals() -> [ArgonLocalVariableNode]
    func allTraits() -> [ArgonTraitsNode]
    }

