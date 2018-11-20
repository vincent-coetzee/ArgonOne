//
//  ArgonName.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ArgonName:Hashable,ExpressibleByStringLiteral,CustomStringConvertible,CustomDebugStringConvertible,Comparable
    {
    public static func < (lhs: ArgonName, rhs: ArgonName) -> Bool
        {
        return(lhs.string < rhs.string)
        }
    
    public static func +(lhs:ArgonName,rhs:String) -> ArgonName
        {
        return(ArgonName(lhs) + ArgonName(rhs))
        }
    
    public static func +(lhs:ArgonName,rhs:ArgonName) -> ArgonName
        {
        var components = lhs.components
        components.append(contentsOf: rhs.components)
        return(ArgonName(components))
        }
    
    public var debugDescription: String
        {
        return(self.description)
        }
    
    public var description: String
        {
        return(components.joined(separator: "::"))
        }
    
    public typealias StringLiteralType = String
    
    public static let null = ArgonName()
    
    var components:[String] = []
    
    public var count:Int
        {
        return(components.count)
        }
    
    public var last:String
        {
        return(components.last!)
        }
    
    public var first:String
        {
        return(components[0])
        }
    
    public var second:String
        {
        return(components[0])
        }
    
    public var third:String
        {
        return(components[0])
        }
    
    public var string:String
        {
        return(components.joined(separator: "::"))
        }
    
    init()
        {
        }
    
    public init(_ name:ArgonName)
        {
        self.components = name.components
        }

    public init(stringLiteral string:String)
        {
        components = string.components(separatedBy: "::")
        }
    
    public init(_ string:String)
        {
        components = string.components(separatedBy: "::")
        }
    
    init(_ name:String,_ name1:String)
        {
        components = [name,name1]
        }
    
    init(_ name:[String])
        {
        components = name
        }
    
    init(_ name:String?)
        {
        if name != nil
            {
            components = [name!]
            }
        }
    
    public func appending(_ piece:String) -> ArgonName
        {
        var nodes = components
        nodes.append(piece)
        return(ArgonName(nodes))
        }
    }
