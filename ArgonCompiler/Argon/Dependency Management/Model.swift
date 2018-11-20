//
//  Model.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol Model:NSObjectProtocol
    {
    var dependents:DependentSet { get }
    func add(dependent:Dependent)
    func remove(dependent:Dependent)
    func changed(aspect:String,with:Any?,from:Model)
    }

extension Model
    {
    public func add(dependent: Dependent)
        {
        self.dependents.add(dependent:dependent)
        }
    
    public func remove(dependent: Dependent)
        {
        self.dependents.remove(dependent:dependent)
        }
    
    public func changed(aspect: String,with: Any?,from: Model)
        {
        self.dependents.update(aspect:aspect,with:with,from:from)
        }
    }
