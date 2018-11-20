//
//  ThreeAddressPointer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ThreeAddressContentsOfPointer:ThreeAddress
    {
    public private(set) var pointer:ThreeAddressPointer
    
    public var isLocal: Bool
        {
        return(false)
        }
    
    public var isConstant: Bool
        {
        return(false)
        }
    
    public var isMethod: Bool
        {
        return(false)
        }
    
    public var isParameter: Bool
        {
        return(false)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isStackBased: Bool
        {
        return(false)
        }
    
    public var isPointerDereference:Bool
        {
        return(true)
        }
    
    public var isInteger: Bool
        {
        return(false)
        }
    
    public var locations = ArgonValueLocationList()
    
    init(_ pointer:ThreeAddressPointer)
        {
        self.pointer = pointer
        }
    
    public func isSame(as address: ThreeAddress) -> Bool
        {
        if address is ThreeAddressContentsOfPointer
            {
            if (address as! ThreeAddressContentsOfPointer).pointer.isSame(as: self.pointer)
                {
                return(true)
                }
            }
        return(false)
        }
    
    public var name: ArgonName
        {
        return(ArgonName("*\(pointer.name.string)"))
        }
    
    public var isVariable: Bool
        {
        return(false)
        }
    }

public class ThreeAddressPointer:ThreeAddress
    {
    public static func addressOf(_ address:ThreeAddress) -> ThreeAddressPointer
        {
        return(ThreeAddressPointer(to: address))
        }
    
    public static func addressIn(_ address:ThreeAddress) -> ThreeAddressPointer
        {
        return(ThreeAddressPointer(in: address))
        }

    private var isOf = false
    public private(set) var address:ThreeAddress
    public var locations = ArgonValueLocationList()
    
    public var isPointerIn:Bool
        {
        return(!isOf)
        }
    
    public var isPointerTo:Bool
        {
        return(isOf)
        }
    
    init(to:ThreeAddress)
        {
        address = to
        isOf = true
        }
    
    init(in within:ThreeAddress)
        {
        address = within
        isOf = false
        }
    
    public func isSame(as address: ThreeAddress) -> Bool
        {
        if type(of: address) != type(of: self)
            {
            return(false)
            }
        let other = address as! ThreeAddressPointer
        return(other.isOf == self.isOf && other.address.isSame(as: self.address))
        }
    
    public var name: ArgonName
        {
        if isOf
            {
            return(ArgonName("&\(address.name.string)"))
            }
        else
            {
            return(ArgonName("(\(address.name.string))"))
            }
        }
    
    public var isPointer: Bool
        {
        return(true)
        }
    
    public var isTemporary: Bool
        {
        return(false)
        }
    
    public var isStackBased: Bool
        {
        return(false)
        }
    
    public var isInteger: Bool
        {
        return(false)
        }
        
    public var isMethod: Bool
        {
        return(false)
        }
    
    public var isVariable: Bool
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
    
    public var isParameter: Bool
        {
        return(false)
        }
    }
