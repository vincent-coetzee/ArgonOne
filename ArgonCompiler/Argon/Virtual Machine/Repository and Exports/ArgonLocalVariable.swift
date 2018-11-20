//
//  ArgonLocalVariable.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/06.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonLocalVariable:ArgonModulePart
    {
    public var traits:ArgonTraits
    
    public override init(fullName:String)
        {
        self.traits = ArgonRelocationTable.shared.traits(at: "Argon::Void")!
        super.init(fullName:fullName)
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(traits,forKey:"traits")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        traits = aDecoder.decodeObject(forKey: "traits") as! ArgonTraits
        super.init(coder:aDecoder)
        }
    }
