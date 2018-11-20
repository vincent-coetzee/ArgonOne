//
//  ThreeAddressOperation.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/16.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum ThreeAddressOperation
    {
    case none
    case assign
    case add
    case sub
    case mul
    case div
    case mod
    case and
    case or
    case not
    case xor
    case jump
    case jumpIfTrue
    case jumpIfFalse
    case param
    case call
    case make
    case jumpIfGTE
    case jumpIfLTE
    case dispatch
    case lt
    case lte
    case eq
    case gt
    case gte
    case vectorElementGet
    case vectorElementSet
    case halt
    case nop
    case ret
    case `return`
    case enter
    case leave
    case prim
    case spawn
    case clear
    
    public var isJump:Bool
        {
        switch(self)
            {
            case .jump:
                fallthrough
            case .jumpIfTrue:
                fallthrough
            case .jumpIfFalse:
                fallthrough
            case .jumpIfGTE:
                fallthrough
            case .jumpIfLTE:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isJumpWithOperand:Bool
        {
        switch(self)
            {
            case .jumpIfTrue:
                return(true)
            case .jumpIfFalse:
                return(true)
            case .jumpIfGTE:
                return(true)
            case .jumpIfLTE:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isJumpWithoutOperand:Bool
        {
        switch(self)
            {
            case .jump:
                return(true)
            default:
                return(false)
            }
        }
    }
