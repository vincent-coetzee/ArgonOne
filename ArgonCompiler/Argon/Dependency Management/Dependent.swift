//
//  Dependent.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol Dependent:NSObjectProtocol
    {
    func update(aspect:String,with:Any?,from:Model)
    }
