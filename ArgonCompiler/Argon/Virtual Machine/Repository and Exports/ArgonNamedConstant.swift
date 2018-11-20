//
//  ArgonNamedConstant.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/03.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonNamedConstant:ArgonModulePart
    {
    public var kind: ArgonModuleItemKind
    fileprivate var value:Any
    
    init(fullName:String,integer:Int)
        {
        self.kind = .integer
        self.value = integer
        super.init(fullName:fullName)
        }
    
    init(fullName:String,boolean:Bool)
        {
        self.value = boolean
        self.kind = .boolean
        super.init(fullName:fullName)
        }
    
    init(fullName:String,string:String)
        {
        self.value = string
        self.kind = .string
        super.init(fullName:fullName)
        }
    
    init(fullName:String,float:Float)
        {
        self.value = float
        self.kind = .float
        super.init(fullName:fullName)
        }
    
    init(fullName:String,symbol:String)
        {
        self.value = symbol
        self.kind = .symbol
        super.init(fullName:fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(kind.rawValue,forKey:"kind")
        switch(kind)
            {
            case .boolean:
                aCoder.encode(value as! Bool,forKey:"value")
            case .symbol:
                aCoder.encode(value as! String,forKey:"value")
            case .string:
                aCoder.encode(value as! String,forKey:"value")
            case .integer:
                aCoder.encode(value as! Int,forKey:"value")
            case .float:
                aCoder.encode(value as! Float,forKey:"value")
            default:
                break
            }
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        kind = ArgonModuleItemKind(rawValue: aDecoder.decodeInteger(forKey: "kind"))!
        switch(kind)
            {
            case .boolean:
                value = aDecoder.decodeBool(forKey:"value")
            case .symbol:
                value = aDecoder.decodeObject(forKey:"value") as! String
            case .string:
                value = aDecoder.decodeObject(forKey:"value") as! String
            case .integer:
                value = aDecoder.decodeInteger(forKey: "value")
            case .float:
                value = aDecoder.decodeFloat(forKey: "value")
            default:
                value = aDecoder.decodeFloat(forKey: "value")
            }
        super.init(coder: aDecoder)
        }
    }
