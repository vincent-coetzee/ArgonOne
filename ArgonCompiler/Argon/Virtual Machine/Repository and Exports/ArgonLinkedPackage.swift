//
//  ArgonLinkedPackage.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public struct ArgonLinkedPackage
    {
    public let vm:VirtualMachine
    public let memory:Memory
    public var packageSizeInBytes = 0
    public var traitsCount = 0
    public var methodCount = 0
    public var closureCount = 0
    public var linkedRelocations:ArgonRelocationTable
    public var module:ArgonModule
    private var mainThread:VMThread?
    
    public var fullName:String
        {
        return(module.fullName)
        }
    
    public var moduleIcon:NSImage
        {
        if module.isExecutable
            {
            return(NSImage(named:"ArgonExecutableIcon")!)
            }
        else
            {
            return(NSImage(named:"ArgonLibraryIcon")!)
            }
        }
    
    init(linker:ArgonLinker)
        {
        self.vm = linker.vm!
        self.memory = self.vm.memory
        self.linkedRelocations = linker.relocations
        self.module = linker.module!
        self.updateCounts(from: linker)
        }
    
    public mutating func updateCounts(from linker:ArgonLinker)
        {
        self.packageSizeInBytes = linker.packageSizeInBytes
        self.closureCount = linker.closureCount
        self.methodCount = linker.methodCount
        self.traitsCount = linker.traitsCount
        }
    
    public mutating func run() throws
        {
        try prepareForRun().run()
        }
    
    public mutating func prepareForRun() throws -> VMThread
        {
        guard module.isExecutable else
            {
            throw(RuntimeError.librariesCanNotRun)
            }
        let executable = module as! ArgonExecutable
        mainThread = VMThread(vm: vm, codeBlock: executable.entryPointCodePointer!, IP: 0,capacity: ArgonWord(Argon.kDefaultThreadMemorySize))
        return(mainThread!)
        }
    }
