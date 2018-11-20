//
//  ArgonLibrary.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonLibrary:ArgonModule
    {
    public var exports:[String:ArgonExport] = [:]
    public var libraryInit:ArgonCodeBlock = ArgonCodeBlock()
    public var genericMethods:[ArgonGenericMethod] = []
    public var constants:[ArgonNamedConstant] = []
    public var globals:[ArgonGlobal] = []
    
    public override var isLibrary:Bool
        {
        return(true)
        }
    
    public override init(fullName:String)
        {
        super.init(fullName:fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(exports,forKey:"exports")
        aCoder.encode(libraryInit,forKey:"libraryInit")
        aCoder.encode(genericMethods,forKey:"genericMethods")
        aCoder.encode(constants,forKey:"constants")
        aCoder.encode(globals,forKey:"globals")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        exports = aDecoder.decodeObject(forKey: "exports") as! [String:ArgonExport]
        libraryInit = aDecoder.decodeObject(forKey: "libraryInit") as! ArgonCodeBlock
        genericMethods = aDecoder.decodeObject(forKey: "genericMethods") as! [ArgonGenericMethod]
        constants = aDecoder.decodeObject(forKey: "constants") as! [ArgonNamedConstant]
        globals = aDecoder.decodeObject(forKey: "globals") as! [ArgonGlobal]
        super.init(coder:aDecoder)
        }
    }
