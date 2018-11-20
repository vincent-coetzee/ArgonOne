//
//  ArgonInstanceElement.swift
//  ArgonInspector
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class ArgonInstanceElement
    {
    public class func bitString(of value:UInt) -> String
        {
        var bitPattern = UInt(1)
        var string = ""
        for index in 1...64
            {
            string += (value & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        let output = String(String(string.reversed()).dropFirst())
        return(output)
        }
    
    internal var word:UInt64
    public var address:Int = 0
    
    public var bitString:String
        {
        return(ArgonInstanceElement.bitString(of: UInt(word)))
        }
    
    public var cellIdentifier:String
        {
        return("ERROR")
        }
    
    public init(word:UInt64)
        {
        self.word = word
        }
    
    public func initCell(view:NSView?)
        {
        }
    
    public func cellHeight() -> CGFloat
        {
        return(0)
        }
    }
