//
//  Token.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/08/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public enum Keyword:String,CaseIterable,Equatable,Codable
    {
    case NOP
    case DD
    case DF
    case DI
    case DS
    case MOV
    case LDS
    case SDS
    case LD
    case LDH
    case LDHS
    case LDQ
    case LDQS
    case LB
    case ENTRY
    case EXIT
    case PRIM
    case CALL
    case RET
    case ADD
    case SUB
    case MUL
    case DIV
    case MOD
    case XOR
    case OR
    case AND
    case ROR
    case ROL
    case BR
    case BRZ
    case BRGT
    case BRGTE
    case BRE
    case BRLTE
    case BRLT
    case EXPORT
    case AS
    case IMPORT
    case LIBRARY
    case EXECUTABLE
    case IP
    case SP
    case BP
    case XP
    case TP
    }

public struct Token:CustomStringConvertible,Codable
    {
    public static let debug = true
    
    let type:TokenType
    var keyword:Keyword!
    var identifier:String!
    var location:SourceLocation!
    var float:Float = 0
    var integer:Int = 0
    var boolean:Bool = false
    var symbol:String = ""
    var string:String = ""
    var register:VMRegister = .NONE
    
    public var description:String
        {
        if type == .keyword
            {
            return("keyword\(keyword!)")
            }
        else if type == .identifier
            {
            return("identifier\(identifier!)")
            }
        else
            {
            return("\(type)")
            }
        }
    
    init(float:Float,_ location:SourceLocation)
        {
        type = .float
        self.float = float
        self.location = location
        }
    
    init(string:String,_ location:SourceLocation)
        {
        type = .string
        self.string = string
        self.location = location
        }
    
    init(integer:Int,_ location:SourceLocation)
        {
        type = .integer
        self.integer = integer
        self.location = location
        }
    
    init(register:VMRegister,_ location:SourceLocation)
        {
        self.register = register
        self.type = .register
        }
    
    init(boolean:Bool,_ location:SourceLocation)
        {
        type = .boolean
        self.boolean = boolean
        self.location = location
        }
    
    init(symbol aType:TokenType,_ location:SourceLocation)
        {
        type = aType
        self.location = location
        }
    
    init(keyword:Keyword,_ location:SourceLocation)
        {
        type = .keyword
        self.keyword = keyword
        self.location = location
        }
    
    init(identifier string:String,_ location:SourceLocation)
        {
        type = .identifier
        identifier = string
        self.location = location
        }
    
    public var isBooleanOperator:Bool
        {
        return(type == .leftBro || type == .lessThanEqual || type == .rightBro || type == .greaterThanEqual || type == .equal)
        }
    
    public var isInteger:Bool
        {
        return(type == .integer)
        }
    
    public var isFloat:Bool
        {
        return(type == .float)
        }
    
    public var isEnd:Bool
        {
        return(type == .end)
        }
    
    public var isColon:Bool
        {
        return(type == .colon)
        }
    
    public var isError:Bool
        {
        return(type == .error)
        }
    
    public var isString:Bool
        {
        return(type == .string)
        }
    
    public var isNumber:Bool
        {
        return(type == .integer || type == .float)
        }
    
    public var isEntry:Bool
        {
        return(type == .keyword && keyword == .ENTRY)
        }
    
    public var isRegister:Bool
        {
        return(type == .register)
        }
    
    public var isBP:Bool
        {
        return(type == .keyword && keyword == .BP)
        }
    
    public var isSP:Bool
        {
        return(type == .keyword && keyword == .SP)
        }
    
    public var isXP:Bool
        {
        return(type == .keyword && keyword == .XP)
        }
    
    public var isITP:Bool
        {
        return(type == .keyword && keyword == .TP)
        }
    
    public var isEexir:Bool
        {
        return(type == .keyword && keyword == .EXIT)
        }
    
    public var isPrimitive:Bool
        {
        return(type == .keyword && keyword == .PRIM)
        }
    
    public var isCall:Bool
        {
        return(type == .keyword && keyword == .CALL)
        }
    
    public var isRet:Bool
        {
        return(type == .keyword && keyword == .RET)
        }
    
    public var isLeftBro:Bool
        {
        return(type == .leftBro)
        }
    
    public var isAssign:Bool
        {
        return(type == .assign)
        }
    
    public var isRightBro:Bool
        {
        return(type == .rightBro)
        }
    
    public var isComma:Bool
        {
        return(type == .comma)
        }
    
    public var isPlus:Bool
        {
        return(type == .plus)
        }
    
    public var isMinus:Bool
        {
        return(type == .minus)
        }
    
    public var isConditional:Bool
        {
        return(type == .leftBro || type == .equal || type == .lessThanEqual || type == .rightBro || type == .greaterThanEqual)
        }
    
    public var isStop:Bool
        {
        return(type == .stop)
        }
    
    public var isLeftPar:Bool
        {
        return(type == .leftPar)
        }
    
    public var isRightPar:Bool
        {
        return(type == .rightPar)
        }
    
    public var isLeftBra:Bool
        {
        return(type == .leftBra)
        }
    
    public var isRightBra:Bool
        {
        return(type == .rightBra)
        }
    
    public var isLeftBrace:Bool
        {
        return(type == .leftBrace)
        }
    
    public var isMul:Bool
        {
        return(type == .mul)
        }
    
    public var isAnd:Bool
        {
        return(type == .and)
        }
    
    public var isBitAnd:Bool
        {
        return(type == .bitAnd)
        }
    
    public var isBitOr:Bool
        {
        return(type == .bitOr)
        }
    
    public var isOr:Bool
        {
        return(type == .or)
        }
    
    public var isBitXor:Bool
        {
        return(type == .bitXor)
        }
    
    public var isBitNot:Bool
        {
        return(type == .bitNot)
        }
    
    public var isNot:Bool
        {
        return(type == .not)
        }
    
    public var isDiv:Bool
        {
        return(type == .div)
        }
    
    public var isMod:Bool
        {
        return(type == .mod)
        }
    
    public var isResult:Bool
        {
        return(type == .result)
        }
    
    public var isRightBrace:Bool
        {
        return(type == .rightBrace)
        }
    
    public var isPercent:Bool
        {
        return(type == .percent)
        }
    
    public var isKeyword:Bool
        {
        switch(type)
            {
            case .keyword:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isIdentifier:Bool
        {
        switch(type)
            {
            case .identifier:
                return(true)
            default:
                return(false)
            }
        }
    
    public var hasLocation:Bool
        {
        switch(type)
            {
        case .identifier:
            return(true)
        case .keyword:
            return(true)
        default:
            return(false)
            }
        }
    
    public var range:NSRange
        {
        switch(type)
            {
        case .identifier:
            return(NSRange(location:location.lineStart - 1,length:location.lineStart - location.lineStart))
        case .keyword:
            return(NSRange(location:location.lineStart - 1,length:location.lineStart - location.lineStart))
        default:
            return(NSRange(location:0,length:0))
            }
        
        }
    
    public func print()
        {
        if Token.debug
            {
            switch(type)
                {
            case .keyword:
                Swift.print("Keyword(\(keyword!))")
            case .identifier:
                Swift.print("Identifier(\(identifier!))")
            default:
                Swift.print("\(type)")
                }
            }
        }
    }

public enum TokenType:Int,Equatable,Codable
    {
    case character
    case float
    case integer
    case boolean
    case byte
    case string
    case start
    case identifier
    case keyword
    case stop
    case result
    case doubleColon
    case assign
    case semicolon
    case leftBro
    case rightBro
    case colon
    case hash
    case bang
    case percent
    case lessThanEqual
    case greaterThanEqual
    case equal
    case doubleEqual
    case end
    case leftPar
    case rightPar
    case leftBra
    case rightBra
    case leftBrace
    case rightBrace
    case comma
    case error
    case value
    case minus
    case plus
    case mul
    case div
    case mod
    case and
    case or
    case not
    case bitAnd
    case bitOr
    case bitXor
    case bitNot
    case comment
    case register
    
    var isEnd:Bool
        {
        switch(self)
            {
        case .end:
            return(true)
        default:
            return(false)
            }
        }
    
    var isError:Bool
        {
        switch(self)
            {
        case .error:
            return(true)
        default:
            return(false)
            }
        }
    }
