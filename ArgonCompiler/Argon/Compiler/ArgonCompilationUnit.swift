//
//  ArgonCompilableNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/05.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonCompilationUnit
    {
    func threeAddress(pass: ThreeAddressPass) throws
    }
