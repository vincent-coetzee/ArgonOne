//
//  ArgonCompiler.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public typealias ModuleNode = ArgonScopeNode & ArgonCompilationUnit

public class ArgonCompiler
    {
    typealias ContextClosure = (ArgonCompiler) throws -> Void
    
    private var module:ModuleNode!
    private var _currentStackFrame:ArgonStackFrame?
    private var stackFrameStack = Array<ArgonStackFrame?>()
    private var symbolTable:ArgonSymbolTable!
    private var relocationTable = ArgonRelocationTable()
    private var codeContainers:[ArgonCodeContainer] = []
    
    public var source:String = ""
    public var tokenSourceLocation:SourceLocation?
    private var threeAddressPass:ThreeAddressPass?
    
    init()
        {
        }
    
    public func parse() throws
        {
        let parser = ArgonParser()
        do
            {
            module = try ((parser.parse(source) as! ModuleNode))
            if module is ArgonLibraryNode
                {
                ArgonRepository.shared.add(library: (module as! ArgonLibraryNode).asArgonLibrary())
                }
            else if module is ArgonExecutableNode
                {
                ArgonRepository.shared.add(executable: (module as! ArgonExecutableNode).asArgonExecutable())
                }
            }
        catch let error
            {
            self.tokenSourceLocation = parser.tokenSourceLocation
            throw(error)
            }
        codeContainers = parser.codeContainers
        symbolTable = parser.symbolTable
        }
    
    public func compile() throws
        {
        let pass = ThreeAddressPass()
        for container in codeContainers
            {
            try container.threeAddress(pass: pass)
            }
//        try pass.constructBasicBlocks()
//        pass.dumpBasicBlocks()
//        try pass.constructFlowGraph()
//        try pass.performNextUseAndLivenessAnalysis(using: symbolTable)
//        pass.constructDAGs()
        try pass.generateCode(codeContainers)
        relocationTable = ArgonRelocationTable.shared
        try pass.peepholeOptimize(codeContainers)
        try pass.fixupTargets(codeContainers)
        threeAddressPass = pass
        }
    
    public func package(source:String) throws -> ArgonModulePart
        {
        if threeAddressPass != nil
            {
            let container = threeAddressPass!.topLevelContainer!
            if container.isLibrary
                {
                let library = (container as! ArgonLibraryNode).asArgonLibrary()
                library.source = source
                library.prepareForPackaging(relocationTable)
                return(library)
                }
            else
                {
                let executable = (container as! ArgonExecutableNode).asArgonExecutable()
                executable.source = source
                executable.prepareForPackaging(relocationTable)
                return(executable)
                }
            }
        fatalError("Should not get here")
        }

    }
