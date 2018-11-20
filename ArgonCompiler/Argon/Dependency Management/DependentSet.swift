//
//  DependentSet.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class DependentSet
    {
    private var dependents:[Dependent] = []
    
    public func add(dependent:Dependent)
        {
        guard dependents.firstIndex(where: {$0.isEqual(dependent)}) == nil else
            {
            return
            }
        dependents.append(dependent)
        }
    
    public func remove(dependent:Dependent)
        {
        if let index = dependents.firstIndex(where: {$0.isEqual(dependent)})
            {
            dependents.remove(at: index)
            }
        }
    
    public func update(aspect:String,with:Any?,from:Model)
        {
        for dependent in dependents
            {
            dependent.update(aspect:aspect,with:with,from:from)
            }
        }
    }
