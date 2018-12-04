//
//  ArgonHandler.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonHandler:ArgonModulePart
    {
    public private(set) var code:ArgonCodeBlock
    public var conditionSymbol:ArgonSymbol = ArgonSymbol(symbol:"")
    
    public init(fullName:String,code:ArgonCodeBlock)
        {
        self.code = code
        super.init(fullName:fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(code,forKey:"code")
        aCoder.encode(conditionSymbol,forKey:"conditionSymbol")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        code = aDecoder.decodeObject(forKey: "code") as! ArgonCodeBlock
        conditionSymbol = aDecoder.decodeObject(forKey: "conditionSymbol") as! ArgonSymbol
        super.init(coder:aDecoder)
        }
    
    required public init(archiver: CArchiver) throws
        {
        code = try ArgonCodeBlock(archiver: archiver)
        conditionSymbol = try ArgonSymbol(archiver: archiver)
        try super.init(archiver: archiver)
        }
    
    public override func write(archiver: CArchiver) throws
        {
        try archiver.write(object: self)
        try super.write(archiver: archiver)
        try code.write(archiver: archiver)
        try conditionSymbol.write(archiver: archiver)
        }
    }
