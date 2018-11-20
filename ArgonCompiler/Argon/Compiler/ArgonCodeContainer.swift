//
//  ArgonCodeContainer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/03.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ArgonCodeContainer:class
    {
    var id:Int { get }
    var instructionList:VMInstructionList { get set }
    var lastLHS:ThreeAddress { get }
    var isLibrary:Bool { get }
    func add(_ instruction:ThreeAddressInstruction) -> Int
    func generateCode(with: ThreeAddressCodeGenerator) throws
    func fixupTargets() throws
    func peepholeOptimize(using: ArgonPeepholeOptimizer) throws
    func dump()
    func threeAddress(pass: ThreeAddressPass) throws
    }

extension ArgonCodeContainer
    {
    public var isLibrary:Bool
        {
        return(false)
        }
    
    public func threeAddress(pass: ThreeAddressPass) throws
        {
        }
    
    public func fixupTargets() throws
        {
        self.instructionList.fixupTargets()
        }
    
    public func peepholeOptimize(using optimizer: ArgonPeepholeOptimizer) throws
        {
        try optimizer.apply(to: self.instructionList)
        }
    }
