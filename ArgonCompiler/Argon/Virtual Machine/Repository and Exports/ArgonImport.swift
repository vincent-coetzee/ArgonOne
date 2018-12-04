//
//  ArgonImport.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonImport:ArgonModulePart
    {
    public var paths:[String] = []
    public var externalModuleName:String?
    public var internalName:String = ""
    public var itemName:String?
    
    init(fullName:String,paths:[String])
        {
        self.paths = paths
        super.init(fullName: fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(paths,forKey:"paths")
        aCoder.encode(internalName,forKey:"internalName")
        if let name = externalModuleName
            {
            aCoder.encode(name,forKey:"externalModuleName")
            }
        if let name = itemName
            {
            aCoder.encode(name,forKey:"itemName")
            }
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        paths = aDecoder.decodeObject(forKey: "paths") as! [String]
        internalName = aDecoder.decodeObject(forKey: "internalName") as! String
        externalModuleName = aDecoder.decodeObject(forKey: "externalModuleName") as? String
        itemName = aDecoder.decodeObject(forKey: "itemName") as? String
        super.init(coder:aDecoder)
        }
    
    required public init(archiver: CArchiver) throws
        {
        throw(ParseError.notImplemented)
        try super.init(archiver: archiver)
        }
    
    public override func write(archiver: CArchiver) throws
        {
        throw(ParseError.notImplemented)
        try archiver.write(object: self)
        try super.write(archiver: archiver)
        }
    }
