//
//  ArgonMethod.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonMethod:ArgonModulePart
    {
    public var returnType:ArgonTraits
    public var moduleName:String = ""
    public var parameters:[ArgonParameter] = []
    public var code = ArgonCodeBlock()
    public var isPrimitive = false
    public var primitiveNumber = 0
    
    override init(fullName: String)
        {
        self.returnType = ArgonRelocationTable.shared.traits(at: "Argon::Traits")!
        super.init(fullName:fullName)
        }
    
    public func updateParameters(from memory:Memory) throws
        {
        for parameter in parameters
            {
            let traits = parameter.traits
            if pointerAsWord(traits.pointer) < 10
                {
                traits.pointer = try memory.traits(atName: traits.fullName)!
                }
            }
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(returnType,forKey:"returnType")
        aCoder.encode(moduleName,forKey:"moduleName")
        aCoder.encode(parameters,forKey:"parameters")
        aCoder.encode(code,forKey:"code")
        aCoder.encode(isPrimitive,forKey:"isPrimitive")
        aCoder.encode(primitiveNumber,forKey:"primitiveNumber")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        returnType = aDecoder.decodeObject(forKey: "returnType") as! ArgonTraits
        moduleName = aDecoder.decodeObject(forKey: "moduleName") as! String
        parameters = aDecoder.decodeObject(forKey: "parameters") as! [ArgonParameter]
        code = aDecoder.decodeObject(forKey: "code") as! ArgonCodeBlock
        isPrimitive = aDecoder.decodeBool(forKey: "isPrimitive")
        primitiveNumber = aDecoder.decodeInteger(forKey: "primitiveNumber")
        super.init(coder:aDecoder)
        }
    
    required public init(archiver: CArchiver) throws
        {
        returnType = try ArgonTraits(archiver: archiver)
        moduleName = try String(archiver: archiver)
        parameters = try [ArgonParameter](archiver: archiver)
        code = try ArgonCodeBlock(archiver: archiver)
        isPrimitive = try Bool(archiver: archiver)
        primitiveNumber = try Int(archiver: archiver)
        try super.init(archiver: archiver)
        }
    
    public override func write(archiver: CArchiver) throws
        {
        try archiver.write(object: self)
        try super.write(archiver: archiver)
        try returnType.write(archiver: archiver)
        try moduleName.write(archiver: archiver)
        try parameters.write(archiver: archiver)
        try code.write(archiver: archiver)
        try isPrimitive.write(archiver: archiver)
        try primitiveNumber.write(archiver: archiver)
        }
    }
