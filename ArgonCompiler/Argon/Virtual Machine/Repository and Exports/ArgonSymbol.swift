//
//  ArgonSymbol.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/12.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonSymbol:ArgonString
    {
    public init(symbol:String)
        {
        super.init(string:symbol)
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        super.init(coder:aDecoder)
        }
    
    required public init(archiver: CArchiver) throws
        {
        let aString = try String(archiver: archiver)
        try super.init(string:aString)
        }
    
    public override func write(archiver: CArchiver) throws
        {
        try archiver.write(object: self)
        try super.write(archiver: archiver)
        try string.write(archiver: archiver)
        }
}
