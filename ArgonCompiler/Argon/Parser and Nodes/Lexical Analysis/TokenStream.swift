//
//  TokenStream.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/08/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct OperatorToken
    {
    var characters:[Character] = []
    var tokenKey:Int = 0
    
    init(characters:[Character],tokenKey:Int)
        {
        self.characters = characters
        self.tokenKey = tokenKey
        }
    }

public struct SourceLocation:Codable
    {
    let lineNumber:Int
    let tokenStart:Int
    let tokenStop:Int
    let lineStart:Int
    let lineStop:Int
    
    init(line:Int,tokenStart:Int,tokenStop:Int,lineStart:Int,lineStop:Int)
        {
        self.lineNumber = line
        self.tokenStart = tokenStart
        self.tokenStop = tokenStop
        self.lineStart = lineStart
        self.lineStop = lineStop
        }
    }

public class TokenStream
    {
    private var source:String = ""
    private var line:Int = 0
    private var currentChar:Unicode.Scalar = " "
    private var offset:String.Index = "".startIndex
    private var currentString:String  = ""
    private var keywords:[String] = []
    private var startIndex:Int = 0
    private let alphanumerics = NSCharacterSet.alphanumerics
    private let letters = NSCharacterSet.letters
    private let digits = NSCharacterSet.decimalDigits
    private let whitespace = NSCharacterSet.whitespaces
    private let newline = NSCharacterSet.newlines
    private let symbols = CharacterSet(charactersIn: "#()[]=:.{},<>-+*/%!&|~^@!$?\\~")
    private var tokenStart:String.Index = "".startIndex
    private var tokenStop:String.Index = "".startIndex
    private var lineStart:String.Index = "".startIndex
    private var lineStop:String.Index = "".startIndex
    private var operatorTokens:[OperatorToken] = []
    public var parseComments:Bool = false
    
    private var atEnd:Bool
        {
        return(offset == source.endIndex)
        }
    
    private var atEndOfLine:Bool
        {
        return(newline.contains(currentChar))
        }
    
    init()
        {
        source = ""
        initState()
        initKeywords()
        }
    
    init(source:String)
        {
        self.source = source
        initState()
        initKeywords()
        }
    
    public func setSource(_ string:String)
        {
        source = string
        initState()
        }
    
    private func initState()
        {
        tokenStart = "".startIndex
        tokenStop = "".startIndex
        lineStart = "".startIndex
        lineStop  = "".startIndex
        startIndex = 0
        line = 1
        currentChar = Unicode.Scalar(" ")
        offset = source.startIndex
        }
    
    @discardableResult
    @inline(__always)
    private func nextChar() -> Unicode.Scalar
        {
        guard !self.atEnd else
            {
            currentChar = Unicode.Scalar(0)
            return(" ")
            }
        currentChar = source.unicodeScalars[offset]
        offset = source.index(after:offset)
        if newline.contains(currentChar)
            {
            lineStart = source.index(after:lineStop)
            lineStop = offset
            }
        return(currentChar)
        }
    
    public func addOperatorToken(characters:[Character],for index:Int)
        {
        operatorTokens.append(OperatorToken(characters:characters,tokenKey:index))
        }
    
    public func rewindChar()
        {
        offset = source.index(before: offset)
        currentChar = source.unicodeScalars[offset]
        }
    
    private func eatSpace() throws
        {
        while (whitespace.contains(currentChar) || newline.contains(currentChar)) && !atEnd
            {
            if whitespace.contains(currentChar)
                {
                try eatWhitespace()
                }
            if newline.contains(currentChar)
                {
                try eatNewline()
                }
            }
        }
    
    @inline(__always)
    private func scanToEndOfLine() throws
        {
        while !newline.contains(currentChar) && !atEnd
            {
            nextChar()
            }
        }
    
    @inline(__always)
    private func scanToEndOfComment() throws
        {
        while currentChar != "*" && !atEnd
            {
            nextChar()
            }
        nextChar()
        if currentChar == "/"
            {
            nextChar()
            return
            }
        try scanToEndOfComment()
        }
    
    public func nextToken() throws -> Token
        {
        tokenStart = offset
        try eatSpace()
        if currentChar == "/" && !atEnd
            {
            nextChar()
            if currentChar == "/" && !atEnd
                {
                startIndex = source.distance(from: source.startIndex, to: offset)
                try scanToEndOfLine()
                if parseComments
                    {
                    return(Token(symbol: .comment,self.sourceLocation()))
                    }
                return(try self.nextToken())
                }
            else if currentChar == "*" && !atEnd
                {
                startIndex = source.distance(from: source.startIndex, to: offset)
                try scanToEndOfComment()
                if parseComments
                    {
                    return(Token(symbol: .comment,self.sourceLocation()))
                    }
                return(try self.nextToken())
                }
            else
                {
                return(Token(symbol:.div,self.sourceLocation()))
                }
            }
        currentString = ""
        startIndex = source.distance(from: source.startIndex, to: offset)
        if letters.contains(currentChar)
            {
            return(try self.nextIdentifier())
            }
        else if digits.contains(currentChar)
            {
            return(try self.nextNumber())
            }
        else if currentChar == "\""
            {
            return(try self.nextString())
            }
        else if symbols.contains(currentChar)
            {
            return(try self.nextSymbol())
            }
        else if atEnd
            {
            return(Token(symbol: .end,self.sourceLocation()))
            }
        throw(ParseError.invalidCharacter(""))
        }
    
    private func nextString() throws -> Token
        {
        var string = ""
        nextChar()
        while currentChar != "\"" && !atEnd
            {
            string += String(currentChar)
            nextChar()
            }
        nextChar()
        return(Token(string: string,self.sourceLocation()))
        }
    
    @inline(__always)
    private func eatNewline() throws
        {
        while newline.contains(currentChar) && !atEnd
            {
            nextChar()
            }
        line += 1
        }
    
    @inline(__always)
    private func eatWhitespace() throws
        {
        while whitespace.contains(currentChar) && !self.atEnd
            {
            self.nextChar()
            }
        }
    
    private func nextNumber() throws -> Token
        {
        var number:Int = 0
        while (digits.contains(currentChar) || currentChar == "_") && !atEnd
            {
            if currentChar == "_"
                {
                nextChar()
                }
            if digits.contains(currentChar)
                {
                number *= 10
                number += Int(String(currentChar))!
                nextChar()
                }
            }
        if currentChar == "."
            {
            nextChar()
            var factor = Float(0.0)
            var divisor = 10
            while (digits.contains(currentChar) || currentChar == "_") && !atEnd
                {
                if currentChar == "_"
                    {
                    nextChar()
                    }
                if digits.contains(currentChar)
                    {
                    factor += Float(String(currentChar))! / Float(divisor)
                    divisor *= 10
                    nextChar()
                    }
                }
            return(Token(float: Float(Float(number)+factor),self.sourceLocation()))
            }
        return(Token(integer: number,self.sourceLocation()))
        }
    
    private func nextByte() throws -> Token
        {
        var number:Int = 0
        while (digits.contains(currentChar)) && !atEnd
            {
            if digits.contains(currentChar)
                {
                number *= 10
                number += Int(String(currentChar))!
                nextChar()
                }
            number &= 255
            }
        return(Token(byte: UInt8(number),self.sourceLocation()))
        }
    
    private func nextIdentifier() throws -> Token
        {
        repeat
            {
            currentString.append(String(currentChar))
            self.nextChar()
            }
        while isIdentifierCharacter(currentChar) && !self.atEnd && !self.atEndOfLine
        let aToken = checkForKeywordOrIdentifier(currentString)
        return(aToken)
        }
    
    private func checkForKeywordOrIdentifier(_ string:String) -> Token
        {
        if keywords.contains(string)
            {
            return(Token(keyword: Keyword(rawValue:string)!,self.sourceLocation()))
            }
        return(Token(identifier: string,self.sourceLocation()))
        }
    
    @inline(__always)
    private func isIdentifierCharacter(_ character:Unicode.Scalar) -> Bool
        {
        if alphanumerics.contains(character)
            {
            return(true)
            }
        if character == "-" || character == "_"
            {
            return(true)
            }
        return(false)
        }
    
    private func currentCharactersMatch(token:OperatorToken) -> Bool
        {
        var unwindCount = 0
        for index in 0..<token.characters.count
            {
            if Character(currentChar) != token.characters[index]
                {
                for _ in 0..<unwindCount
                    {
                    self.rewindChar()
                    }
                return(false)
                }
            self.nextChar()
            unwindCount += 1
            }
        return(true)
        }
    
    private func nextOperatorToken() throws -> OperatorToken?
        {
        for token in operatorTokens
            {
            if self.currentCharactersMatch(token: token)
                {
                return(token)
                }
            }
        return(nil)
        }
    
    private func nextSymbol() throws -> Token
        {
        if let operatorToken = try self.nextOperatorToken()
            {
            return(Token(operator:operatorToken.tokenKey,self.sourceLocation()))
            }
        else if currentChar == "#"
            {
            nextChar()
            var string = "#"
            while alphanumerics.contains(currentChar)
                {
                string += String(currentChar)
                nextChar()
                }
            return(Token(symbol:string,self.sourceLocation()))
            }
        else if currentChar == "&"
            {
            nextChar()
            if currentChar == "&"
                {
                nextChar()
                return(Token(symbol: .and,self.sourceLocation()))
                }
            return(Token(symbol: .bitAnd,self.sourceLocation()))
            }
        else if currentChar == "|"
            {
            nextChar()
            if currentChar == "|"
                {
                nextChar()
                return(Token(symbol: .or,self.sourceLocation()))
                }
            return(Token(symbol: .bitOr,self.sourceLocation()))
            }
        else if currentChar == "~"
            {
            nextChar()
            return(Token(symbol: .bitNot,self.sourceLocation()))
            }
        else if currentChar == "@"
            {
            nextChar()
            return(Token(symbol: .at,self.sourceLocation()))
            }
        else if currentChar == "^"
            {
            nextChar()
            return(Token(symbol: .bitXor,self.sourceLocation()))
            }
        else if currentChar == "+"
            {
            nextChar()
            return(Token(symbol: .plus,self.sourceLocation()))
            }
        else if currentChar == "*"
            {
            nextChar()
            return(Token(symbol: .mul,self.sourceLocation()))
            }
        else if currentChar == "%"
            {
            nextChar()
            return(Token(symbol: .mod,self.sourceLocation()))
            }
        else if currentChar == "("
            {
            nextChar()
            return(Token(symbol: .leftPar,self.sourceLocation()))
            }
        else if currentChar == ")"
            {
            nextChar()
            return(Token(symbol:.rightPar,self.sourceLocation()))
            }
        else if currentChar == "["
            {
            nextChar()
            return(Token(symbol: .leftBra,self.sourceLocation()))
            }
        else if currentChar == "]"
            {
            nextChar()
            return(Token(symbol:.rightBra,self.sourceLocation()))
            }
        else if currentChar == "$"
            {
            nextChar()
            return(try self.nextByte())
            }
        else if currentChar == ":"
            {
            nextChar()
            if currentChar == ":"
                {
                nextChar()
                return(Token(symbol:.doubleColon,self.sourceLocation()))
                }
            return(Token(symbol:.colon,self.sourceLocation()))
            }
        else if currentChar == "="
            {
            nextChar()
            if currentChar == "="
                {
                nextChar()
                return(Token(symbol:.equal,self.sourceLocation()))
                }
            return(Token(symbol:.assign,self.sourceLocation()))
            }
        else if currentChar == ">"
            {
            nextChar()
            if currentChar == "="
                {
                nextChar()
                return(Token(symbol:.greaterThanEqual,self.sourceLocation()))
                }
            return(Token(symbol:.rightBro,self.sourceLocation()))
            }
        else if currentChar == "<"
            {
            nextChar()
            if currentChar == "="
                {
                nextChar()
                return(Token(symbol:.lessThanEqual,self.sourceLocation()))
                }
            return(Token(symbol:.leftBro,self.sourceLocation()))
            }
        else if currentChar == "."
            {
            nextChar()
            return(Token(symbol: .stop,self.sourceLocation()))
            }
        else if currentChar == "}"
            {
            nextChar()
            return(Token(symbol:.rightBrace,self.sourceLocation()))
            }
        else if currentChar == "{"
            {
            nextChar()
            return(Token(symbol: .leftBrace,self.sourceLocation()))
            }
        else if currentChar == ","
            {
            nextChar()
            return(Token(symbol:.comma,self.sourceLocation()))
            }
        else if currentChar == "!"
            {
            nextChar()
            return(Token(symbol:.not,self.sourceLocation()))
            }
        else if currentChar == "$"
            {
            nextChar()
            return(Token(symbol:.dollar,self.sourceLocation()))
            }
        else if currentChar == "-"
            {
            nextChar()
            if currentChar == ">"
                {
                nextChar()
                return(Token(symbol:.result,self.sourceLocation()))
                }
            return(Token(symbol:.minus,self.sourceLocation()))
            }
        throw(ParseError.invalidCharacter(String(currentChar)))
        }
    
    private func sourceLocation() -> SourceLocation
        {
        tokenStop = offset
        return(SourceLocation(line:line,tokenStart:max(source.distance(from: source.startIndex,to: tokenStart)-1,0),tokenStop:source.distance(from: source.startIndex, to: tokenStop)-1,lineStart:source.distance(from: source.startIndex,to: lineStart),lineStop:source.distance(from: source.startIndex,to: lineStop)))
        }
    
    private func initKeywords()
        {
        for keyword in Keyword.allCases
            {
            keywords.append(keyword.rawValue)
            }
        }
    }
