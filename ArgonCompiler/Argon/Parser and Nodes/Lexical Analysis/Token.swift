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
    case symbol
    case traits
    case `let`
    case `as`
    case export
    case library
    case executable
    case module
    case date
    case `in`
    case string
    case integer
    case boolean
    case double
    case byte
    case any
    case `true`
    case `false`
    case `is`
    case `if`
    case `else`
    case method
    case `for`
    case `while`
    case character
    case `import`
    case entrypoint
    case `return`
    case sequence
    case to
    case by
    case from
    case `switch`
    case `case`
    case otherwise
    case void = "Void"
    case made
    case this
    case nextMethod
    case constant
    case with
    case primitive
    case spawn
    case inline
    case dynamic
    case system
    case `static`
    case macro
    case handler
    case signal
    case resume
    case `operator`
    case infix
    case prefix
    case postfix
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
    var double:Double = 0
    var byte:UInt8 = 0
    
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
    
    init(double:Double,_ location:SourceLocation)
        {
        type = .double
        self.double = double
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
    
    init(byte:UInt8,_ location:SourceLocation)
        {
        type = .byte
        self.byte = byte
        self.location = location
        }
    
    init(boolean:Bool,_ location:SourceLocation)
        {
        type = .boolean
        self.boolean = boolean
        self.location = location
        }
    
    init(symbol:String,_ location:SourceLocation)
        {
        type = .symbol
        self.symbol = symbol
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
        return(type == .symbol && (type == .leftBro || type == .lessThanEqual || type == .rightBro || type == .greaterThanEqual || type == .equal))
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
    
    public var number:Number
        {
        if type == .integer
            {
            return(Number.integer(integer))
            }
        else if type == .float
            {
            return(Number.float(float))
            }
        else
            {
            return(Number.double(double))
            }
        }
    
    public var isError:Bool
        {
        return(type == .error)
        }
    
    public var isString:Bool
        {
        return(type == .string)
        }
    
    public var isDouble:Bool
        {
        return(type == .double)
        }
    
    public var isByte:Bool
        {
        return(type == .byte)
        }
    
    public var isNumber:Bool
        {
        return(type == .integer || type == .float || type == .double)
        }
    
    public var isMethod:Bool
        {
        return(type == .keyword && keyword == .method)
        }
    
    public var isOperator:Bool
        {
        return(type == .keyword && keyword == .operator)
        }
    
    public var isPrefix:Bool
        {
        return(type == .keyword && keyword == .prefix)
        }
    
    public var isPostfix:Bool
        {
        return(type == .keyword && keyword == .postfix)
        }
    
    public var isInfix:Bool
        {
        return(type == .keyword && keyword == .infix)
        }
    
    public var isDirective:Bool
        {
        return(type == .keyword && (keyword == .static || keyword == .dynamic || keyword == .system || keyword == .inline))
        }
    
    public var isWith:Bool
        {
        return(type == .keyword && keyword == .with)
        }
    
    public var isThis:Bool
        {
        return(type == .keyword && keyword == .this)
        }
    
    public var isMacro:Bool
        {
        return(type == .keyword && keyword == .macro)
        }
    
    public var isConstant:Bool
        {
        return(type == .keyword && keyword == .constant)
        }
    
    public var isSpawn:Bool
        {
        return(type == .keyword && keyword == .spawn)
        }
    
    public var isHandler:Bool
        {
        return(type == .keyword && keyword == .handler)
        }
    
    public var isResume:Bool
        {
        return(type == .keyword && keyword == .resume)
        }
    
    public var isSignal:Bool
        {
        return(type == .keyword && keyword == .signal)
        }
    
    public var isBoolean:Bool
        {
        return(type == .symbol && (symbol == "#true" || symbol == "#false"))
        }
        
    public var isNextMethod:Bool
        {
        return(type == .keyword && keyword == .nextMethod)
        }
    
    public var isFor:Bool
        {
        return(type == .keyword && keyword == .for)
        }
    
    public var isMade:Bool
        {
        return(type == .keyword && keyword == .made)
        }
    
    public var isOtherwise:Bool
        {
        return(type == .keyword && keyword == .otherwise)
        }
    
    public var isFrom:Bool
        {
        return(type == .keyword && keyword == .from)
        }
    
    public var isPrimitive:Bool
        {
        return(type == .keyword && keyword == .primitive)
        }
    
    public var isSequence:Bool
        {
        return(type == .keyword && keyword == .sequence)
        }
    
    public var isTo:Bool
        {
        return(type == .keyword && keyword == .to)
        }
    
    public var isBy:Bool
        {
        return(type == .keyword && keyword == .by)
        }
    
    public var isSymbol:Bool
        {
        return(type == .symbol)
        }
    
    public var isTrue:Bool
        {
        return(type == .keyword && keyword == .true)
        }
    
    public var isFalse:Bool
        {
        return(type == .keyword && keyword == .false)
        }
    
    public var isLet:Bool
        {
        return(type == .keyword && keyword == .let)
        }
    
    public var isEntryPoint:Bool
        {
        return(type == .keyword && keyword == .entrypoint)
        }
    
    public var isImport:Bool
        {
        return(type == .keyword && keyword == .import)
        }
    
    public var isExport:Bool
        {
        return(type == .keyword && keyword == .export)
        }
    
    public var isTraits:Bool
        {
        return(type == .keyword && keyword == .traits)
        }
    
    public var isLibrary:Bool
        {
        return(type == .keyword && keyword == .library)
        }
    
    public var isExecutable:Bool
        {
        return(type == .keyword && keyword == .executable)
        }
    
    public var isAs:Bool
        {
        return(type == .keyword && keyword == .as)
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
    
    public var isIn:Bool
        {
        return(type == .keyword && keyword == .in)
        }
    
    public var isConditional:Bool
        {
        return(type == .leftBro || type == .equal || type == .lessThanEqual || type == .rightBro || type == .greaterThanEqual)
        }
    
    public var isStop:Bool
        {
        return(type == .stop)
        }
    
    public var isConjunction:Bool
        {
        return(type == .doubleColon)
        }
    
    public var isIf:Bool
        {
        return(type == .keyword && keyword == .if)
        }
    
    public var isWhile:Bool
        {
        return(type == .keyword && keyword == .while)
        }
    
    public var isReturn:Bool
        {
        return(type == .keyword && keyword == .return)
        }
    
    public var isElse:Bool
        {
        return(type == .keyword && keyword == .else)
        }
    
    public var isVoid:Bool
        {
        return(type == .keyword && keyword == .void)
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
    
    public var isAt:Bool
        {
        return(type == .at)
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
    
    public var isModule:Bool
        {
        return(type == .keyword && keyword == .module)
        }
    
    public var isSwitch:Bool
        {
        return(type == .keyword && keyword == .switch)
        }
    
    public var isCase:Bool
        {
        return(type == .keyword && keyword == .case)
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
    case double
    case date
    case symbol
    case symbolSet
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
    case method
    case traits
    case local
    case at
    
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
