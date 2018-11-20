//
//  ThreeAddress.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol ThreeAddress
    {
    func isSame(as:ThreeAddress) -> Bool
    var name:ArgonName { get }
    var isVariable:Bool { get }
    var isParameter:Bool { get }
    var isLocal:Bool { get }
    var isConstant:Bool { get }
    var isInteger:Bool { get }
    var isTemporary:Bool { get }
    var isMethod:Bool { get }
    var isStackBased:Bool { get }
    var isPointer:Bool { get }
    var isPointerDereference:Bool { get }
    var isSlot:Bool { get }
    var isClosure:Bool { get }
    var isCapturedValue:Bool { get }
    var isGlobal:Bool { get }
    var locations:ArgonValueLocationList { get }
    }

extension ThreeAddress
    {
    public var isGlobal:Bool
        {
        return(false)
        }
    
    public var isInteger:Bool
        {
        return(false)
        }
    
    public var isCapturedValue:Bool
        {
        return(false)
        }
    
    public var isSlot:Bool
        {
        return(false)
        }
    
    public var isPointer:Bool
        {
        return(false)
        }
    
    public var isClosure:Bool
        {
        return(false)
        }
    
    public var isPointerDereference:Bool
        {
        return(false)
        }
    }

extension Int:ThreeAddress
    {
    public func isSame(as address:ThreeAddress) -> Bool
        {
        if type(of:address) == type(of:self)
            {
            return(address as! Int == self)
            }
        return(false)
        }
    
    public var isInteger:Bool
        {
        return(true)
        }
    
    public var isPointer:Bool
        {
        return(false)
        }
    
    public var name:ArgonName
        {
        return(ArgonName("Integer(\(self))"))
        }
    
    public var isVariable:Bool
        {
        return(false)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isParameter:Bool
        {
        return(false)
        }
    
    public var isLocal:Bool
        {
        return(false)
        }
    
    public var isConstant:Bool
        {
        return(false)
        }
    
    public var isMemoryBased:Bool
        {
        return(false)
        }
    
    public var isMethod:Bool
        {
        return(false)
        }
    
    public var isStackBased:Bool
        {
        return(false)
        }
    
    public var locations:ArgonValueLocationList
        {
        return(ArgonValueLocationList())
        }
    }
