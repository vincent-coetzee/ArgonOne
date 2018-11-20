//
//  ArgonRepository.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonRepository:AbstractModel,NSCoding
    {
    public private(set) static var shared = ArgonRepository()
    
    private var libraries:[String:ArgonLibrary] = [:]
    private var executables:[String:ArgonExecutable] = [:]
    
    public override init()
        {
        super.init()
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        libraries = aDecoder.decodeObject(forKey: "libraries") as! [String:ArgonLibrary]
        executables = aDecoder.decodeObject(forKey: "executables") as! [String:ArgonExecutable]
        super.init()
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(libraries,forKey:"libraries")
        aCoder.encode(executables,forKey:"executables")
        }
    
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
    
    public static func saveToHomeStore() throws
        {
        let url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let path = url.path + "/ArgonRepository.argonrep"
        NSKeyedArchiver.archiveRootObject(self.shared, toFile: path)
        }
    
    public static func loadFromHomeStore() throws
        {
        let url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let path = url.path + "/ArgonRepository.argonrep"
        guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? ArgonRepository else
            {
            throw(VirtualMachineFault.loadRepositoryFailed)
            }
        self.shared = object
        }
    }
