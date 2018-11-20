//
//  ThreeAddressTarget.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum ThreeAddressTarget:Equatable
    {
    public static func ==(lhs:ThreeAddressTarget,rhs:ThreeAddressTarget) -> Bool
        {
        if case .none = lhs,case .none = rhs
            {
            return(true)
            }
        else if case let .label(string1) = lhs,case let .label(string2) = rhs,string1 == string2
            {
            return(true)
            }
        else if case let .address(address1) = lhs,case let .address(address2) = rhs,address1 == address2
            {
            return(true)
            }
        else if case let .basicBlock(block1) = lhs,case let .basicBlock(block2) = rhs,block1 == block2
            {
            return(true)
            }
        return(false)
        }
    
    case none
    case label(String)
    case address(Int)
    case basicBlock(ThreeAddressBasicBlock)
    case threeAddress(ThreeAddress)
    
    public var threeAddressName:String
        {
        switch(self)
            {
            case .threeAddress(let address):
                return(address.name.string)
            default:
                return("ERROR")
            }
        }
    
    public var isAddress:Bool
        {
        switch(self)
            {
            case .address:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isBasicBlock:Bool
        {
        switch(self)
            {
            case .basicBlock:
                return(true)
            default:
                return(false)
            }
        }
    
    public var targetIP:Int
        {
        switch(self)
            {
            case .address(let IP):
                return(IP)
            default:
                fatalError("Should not be called")
            }
        }
    
    public var targetName:String
        {
        switch(self)
            {
            case .address(let address):
                return("\(address)")
            case .label(let label):
                return(label)
            default:
                return("NONE")
            }
        }
    
    public var targetLabel:String
        {
        switch(self)
            {
            case .label(let label):
                return(label)
            default:
                fatalError("Should not happen")
            }
        }
    }
