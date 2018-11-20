//
//  ArgonString.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonString:ArgonModulePart
    {    
    public private(set) var string:String
    
    public override var hash:Int
        {
        return(self.string.hashValue)
        }
    
    public init(string:String)
        {
        self.string = string
        super.init(fullName: string)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(string,forKey:"string")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        string = aDecoder.decodeObject(forKey: "string") as! String
        super.init(coder: aDecoder)
        }
    }
