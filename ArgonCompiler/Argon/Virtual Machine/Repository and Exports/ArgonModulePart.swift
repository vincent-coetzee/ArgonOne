//
//  ArgonModuleItem.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/03.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonModulePart:NSObject,ArgonRelocatable,NSCoding
    {
    public internal(set) var name:String
    public internal(set) var fullName:String
    public var isInstalled = false
    public var id:Int = -1
    public var pointer:Pointer = wordAsPointer(1)
    
    public override var hash:Int
        {
        if id == -1
            {
            fatalError("Bad id")
            }
        return(id)
        }
    
    public var isExecutable:Bool
        {
        return(false)
        }
    
    public var isLibrary:Bool
        {
        return(false)
        }
    
    init(fullName:String)
        {
        self.name = ArgonName(fullName).last
        self.fullName = fullName
        self.id = Argon.nextCounter
        super.init()
        }
   
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(name,forKey:"name")
        aCoder.encode(fullName,forKey:"fullName")
        aCoder.encode(id,forKey:"id")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        name = aDecoder.decodeObject(forKey: "name") as! String
        fullName = aDecoder.decodeObject(forKey: "fullName") as! String
        id = aDecoder.decodeInteger(forKey: "id")
        super.init()
        }
    }

