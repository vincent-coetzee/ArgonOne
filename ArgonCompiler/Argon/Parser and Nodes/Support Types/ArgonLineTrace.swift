//
//  ArgonTraceElement.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/11.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonLineTrace:NSObject,NSCoding
    {
    public private(set) var line:Int = 0
    public private(set) var lineStart:Int = 0
    public private(set) var lineEnd:Int = 0
    public var IP:Int = 0
    
    init(line:Int,start:Int,end:Int)
        {
        self.line = line
        self.lineStart = start
        self.lineEnd = end
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(line,forKey:"line")
        aCoder.encode(lineStart,forKey:"lineStart")
        aCoder.encode(lineEnd,forKey:"lineEnd")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        line = aDecoder.decodeInteger(forKey: "line")
        lineStart = aDecoder.decodeInteger(forKey: "lineStart")
        lineEnd = aDecoder.decodeInteger(forKey: "lineEnd")
        }
    }
