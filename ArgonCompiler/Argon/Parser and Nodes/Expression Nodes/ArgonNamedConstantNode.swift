//
//  ArgonNamedConstantNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonNamedConstantNode:ArgonConstantNode
    {
    public var symbolTableEntry:ArgonSymbolTableEntry?
    public var fullName:ArgonName = .null
    
    public override var isNamedConstant:Bool
        {
        return(true)
        }
    
    init(fullName:ArgonName,string:String)
        {
        self.fullName = fullName
        super.init(string:string)
        _name = ArgonName(ArgonName(fullName).last)
        }
    
    init(fullName:ArgonName,symbol:Symbol)
        {
        self.fullName = fullName
        super.init(symbol:symbol)
        _name = ArgonName(ArgonName(fullName).last)
        }
    
    init(fullName:ArgonName,float:Float)
        {
        self.fullName = fullName
        super.init(float:float)
        _name = ArgonName(ArgonName(fullName).last)
        }
    
    init(fullName:ArgonName,boolean:Bool)
        {
        self.fullName = fullName
        super.init(boolean:boolean)
        _name = ArgonName(ArgonName(fullName).last)
        }
    
    init(fullName:ArgonName,integer:Int)
        {
        self.fullName = fullName
        super.init(integer:integer)
        _name = ArgonName(ArgonName(fullName).last)
        }
    
    public func asArgonNamedConstant() -> ArgonNamedConstant
        {
        if literalInteger != nil
            {
            return(ArgonNamedConstant(fullName: self.fullName.string,integer: literalInteger!))
            }
        if literalFloat != nil
            {
            return(ArgonNamedConstant(fullName: self.fullName.string,float: literalFloat!))
            }
        if literalBoolean != nil
            {
            return(ArgonNamedConstant(fullName: self.fullName.string,boolean: literalBoolean!))
            }
        if literalString != nil
            {
            return(ArgonNamedConstant(fullName: self.fullName.string,string: literalString!))
            }
        fatalError("Should not happen")
        }
    
    public override func threeAddress(pass: ThreeAddressPass) throws
        {
        try super.threeAddress(pass: pass)
        }
    }
