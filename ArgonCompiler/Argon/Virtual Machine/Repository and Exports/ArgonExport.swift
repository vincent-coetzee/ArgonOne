//
//  ArgonExport.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonExport:ArgonModulePart
    {
    public var internalNames:[String] = []
    public var itemName:String?
    
    public override init(fullName:String)
        {
        super.init(fullName: fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(internalNames,forKey:"internalNames")
        if let name = itemName
            {
            aCoder.encode(name,forKey:"itemName")
            }
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        internalNames = aDecoder.decodeObject(forKey: "internalNames") as! [String]
        itemName = aDecoder.decodeObject(forKey: "itemName") as? String
        super.init(coder:aDecoder)
        }
    }
