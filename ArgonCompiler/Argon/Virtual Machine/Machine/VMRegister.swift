//
//  VMRegister.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum MachineRegister:Int
    {
    public static let kGPROffset = 6
    public static let kFPROffset = 38
    
    case NONE = 0
    case BP
    case SP
    case IP
    case ST
    case LP
    case R0
    case R1
    case R2
    case R3
    case R4
    case R5
    case R6
    case R7
    case R8
    case R9
    case R10
    case R11
    case R12
    case R13
    case R14
    case R15
    case R16
    case R17
    case R18
    case R19
    case R20
    case R21
    case R22
    case R23
    case R24
    case R25
    case R26
    case R27
    case R28
    case R29
    case R30
    case R31
    case F0
    case F1
    case F2
    case F3
    case F4
    case F5
    case F6
    case F7
    case F8
    case F9
    case F10
    case F11
    case F12
    case F13
    case F14
    case F15
    case F16
    case F17
    case F18
    case F19
    case F20
    case F21
    case F22
    case F23
    case F24
    case F25
    case F26
    case F27
    case F28
    case F29
    case F30
    case F31
    
    public var name:String
        {
        switch(self)
            {
            case .NONE:
                return("NONE")
            case .BP:
                return("%BP")
            case .SP:
                return("%SP")
            case .IP:
                return("%IP")
            default:
                return("%\(self.rawValue-1)")
            }
        }
    }

public class VMRegister:Equatable
    {
    public private(set) var register:MachineRegister
    public var isAvailable = true
    public var contents:ThreeAddress?
    
    public static func ==(lhs:VMRegister,rhs:VMRegister) -> Bool
        {
        return(lhs.register == rhs.register)
        }
    
    public var isEmpty:Bool
        {
        return(contents == nil)
        }
    
    public var rawValue:Int
        {
        return(self.register.rawValue)
        }
    
    init(rawValue:Int)
        {
        self.register = MachineRegister(rawValue: rawValue)!
        }
    
    init(rawValue:Int,contents:ThreeAddress)
        {
        self.contents = contents
        self.register = MachineRegister(rawValue: rawValue)!
        }
    
    init(_ register: MachineRegister)
        {
        self.register = register
        }
    
    public func contains(_ value:ThreeAddress) -> Bool
        {
        if contents == nil
            {
            return(false)
            }
        return(contents!.isSame(as: value))
        }
    }
