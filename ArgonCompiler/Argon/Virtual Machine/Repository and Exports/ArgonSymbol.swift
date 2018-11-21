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
}
