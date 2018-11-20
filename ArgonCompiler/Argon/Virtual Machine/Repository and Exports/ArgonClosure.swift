//
//  ArgonClosure.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonClosure:ArgonModulePart
    {
    public var inductionVariables:[String] = []
    public var resultType:ArgonTraits?
    public var code = ArgonCodeBlock()
    
    
    public override init(fullName:String)
        {
        self.resultType = ArgonRelocationTable.shared.traits(at:"Argon::Void")!
        super.init(fullName:fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(inductionVariables,forKey:"inductionVariables")
        aCoder.encode(resultType,forKey:"resultType")
        aCoder.encode(code,forKey:"code")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        code = aDecoder.decodeObject(forKey: "code") as! ArgonCodeBlock
        inductionVariables = aDecoder.decodeObject(forKey: "inductionVariables") as! [String]
        resultType = (aDecoder.decodeObject(forKey: "resultType") as! ArgonTraits)
        super.init(coder:aDecoder)
        }
    }
