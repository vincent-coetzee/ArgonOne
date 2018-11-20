//
//  ArgonExecutable.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonExecutable:ArgonModule
    {
    public var entryPoint = ArgonCodeBlock()
    public var executableInit = ArgonCodeBlock()
    public var entryPointCodePointer:Pointer?
    public var executableInitCodePointer:Pointer?
    
    public var subParts:[ArgonModulePart]
        {
        let entries = self.relocations.entries.filter{$0.item is ArgonClosure || $0.item is ArgonGenericMethod || $0.item is ArgonTraits || $0.item is ArgonGlobal}.map{$0.item as! ArgonModulePart}
        return(entries.sorted(by: {$0.fullName < $1.fullName}))
        }
        
    public override var isExecutable:Bool
        {
        return(true)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(entryPoint,forKey:"entryPoint")
        aCoder.encode(executableInit,forKey:"executableInit")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        executableInit = aDecoder.decodeObject(forKey: "executableInit") as! ArgonCodeBlock
        entryPoint = aDecoder.decodeObject(forKey: "entryPoint") as! ArgonCodeBlock
        super.init(coder:aDecoder)
        }
    
    override init(fullName: String)
        {
        super.init(fullName: fullName)
        }
    }
