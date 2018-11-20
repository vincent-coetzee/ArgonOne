//
//  AbtractModel.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation


public class AbstractModel:NSObject,Model
    {
    public private(set) var dependents = DependentSet()
    }
