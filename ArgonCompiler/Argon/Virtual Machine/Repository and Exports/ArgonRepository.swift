//
//  ArgonRepository.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonRepository:AbstractModel
    {
    public static let shared = ArgonRepository()
    
    private var libraries:[String:ArgonLibrary] = [:]
    private var executables:[String:ArgonExecutable] = [:]
    
    public var executableNames:[String]
        {
        return(executables.keys.sorted())
        }
    
    public func add(library:ArgonLibrary)
        {
        libraries[library.name] = library
        }
    
    public func add(executable:ArgonExecutable)
        {
        executables[executable.name] = executable
        }
    
    public func executable(at name:String) -> ArgonExecutable?
        {
        return(executables[name])
        }
    }
