//
//  Symbol.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/23.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class Symbol:NSObject,ThreeAddress,NSCoding
    {
    private static var symbols:[String:Symbol] = [:]
    
    public static func symbol(_ string:String) -> Symbol
        {
        guard let aSymbol = symbols[string] else
            {
            let newSymbol = Symbol(string)
            symbols[string] = newSymbol
            return(newSymbol)
            }
        return(aSymbol)
        }
    
    public static func ==(lhs:Symbol,rhs:Symbol) -> Bool
        {
        return(lhs.stringValue == rhs.stringValue)
        }
    
    public var name: ArgonName
        {
        return(ArgonName(stringValue))
        }
    
    public var isVariable: Bool
        {
        return(false)
        }
    
    public var isParameter: Bool
        {
        return(false)
        }
    
    public var isLocal: Bool
        {
        return(false)
        }
    
    public var isConstant: Bool
        {
        return(false)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isMethod: Bool
        {
        return(false)
        }
    
    public var isStackBased: Bool
        {
        return(false)
        }
    
    public var string:String
        {
        return(stringValue)
        }
    
    public func isSame(as other: ThreeAddress) -> Bool
        {
        if !(other is Symbol)
            {
            return(false)
            }
        let otherSymbol = other as! Symbol
        if self.stringValue == otherSymbol.stringValue
            {
            return(true)
            }
        return(false)
        }
    
    public var locations = ArgonValueLocationList()
    private let stringValue:String
    
    
    public init(_ string:String)
        {
        self.stringValue = string
        }
    
    public func asArgonSymbol() -> ArgonSymbol
        {
        return(ArgonSymbol(symbol:stringValue))
        }
    
    public func encode(with aCoder: NSCoder)
        {
        aCoder.encode(stringValue,forKey:"stringValue")

        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        stringValue = aDecoder.decodeObject(forKey: "stringValue") as! String
        }
    }
