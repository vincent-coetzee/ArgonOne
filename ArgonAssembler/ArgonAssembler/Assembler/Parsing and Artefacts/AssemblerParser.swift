//
//  AssemblerParser.swift
//  ArgonAssembler
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class AssemblerParser
    {
    private var token:Token = Token(integer: 0,SourceLocation(line:0,tokenStart:0,tokenStop:0,lineStart:0,lineStop:0))
    private var tokenStream:TokenStream!
    
    public func parse(source:String) throws -> ParserNode
        {
        tokenStream = TokenStream(source: source)
        token = try tokenStream.nextToken()
        let node = try parseBlock()
        return(node)
        }
    
    private func nextToken() throws
        {
        self.token = try tokenStream.nextToken()
        }
    
    private func parseBlock() throws -> ParserStatementBlock
        {
        var block = ParserStatementBlock()
        while !token.isEnd
            {
            block.add(statement: try self.parseStatement())
            }
        return(block)
        }
    
    private func parseStatement() throws ->ParserStatement
        {
        var label:String?
        if token.isIdentifier
            {
            label = token.identifier!
            try self.nextToken()
            if !token.isColon
                {
                throw(ParsingError.colonExpectedAfterLabel)
                }
            try self.nextToken()
            }
        if !token.isKeyword
            {
            throw(ParsingError.instructionCodeExpected)
            }
        var statement = try self.parseOpcode()
        statement.label = label
        return(statement)
        }
    
    private func parseOpcode() throws -> ParserStatement
        {
        switch(token.keyword!)
            {
            case .MOV:
                return(try self.parseMove())
            case .BR:
                return(try self.parseBranch())
            case .ENTRY:
                return(try self.parseEntry())
            case .EXIT:
                return(try self.parseExit())
            default:
                throw(ParsingError.undefinedInstructionCode)
            }
        }
    
    private func parseBrackets(_ closure:() throws  -> Void) throws
        {
        if !token.isLeftBra
            {
            throw(ParsingError.leftBraExpected)
            }
        try self.nextToken()
        try closure()
        if !token.isRightBra
            {
            throw(ParsingError.rightBraExpected)
            }
        try self.nextToken()
        }
    
    private func parseMove() throws -> ParserStatement
        {
        try self.nextToken()
        if token.isLeftBra
            {
            
            }
        }
    
    private func parseIndirect() throws -> (VMRegister,Int)
        {
        var hasImmediate = false
        var immediate:Int = 0
        var seenImmediate = false
        var seenRegister = false
        var seenPlus = false
        var register:VMRegister
        try self.parseBrackets
            {
            if !token.isRegister
                {
                throw(ParsingError.registerExpected)
                }
            if token.isInteger
                {
                if seenImmediate
                    {
                    throw(ParsingError.immediateAlreadyDefined)
                    }
                seenImmediate = true
                hasImmediate = true
                immediate = token.integer
                try self.nextToken()
                }
            else if token.isRegister
                {
                if seenRegister
                    {
                    throw(ParsingError.registerAlreadyDefined)
                    }
                register = token.register
                }
            else
                {
                throw(ParsingError.immediateOrRegisterExpected)
                }
            }
        }
    
    private func parseRegister() throws -> VMRegister
        {
        if !token.isPercent
            {
            throw(ParsingError.percentExpected)
            }
        try self.nextToken()
        switch(token)
            {
        case isInteger:
            if token.integer < 0 || token.integer > 31
                {
                throw(ParsingError.invalidRegister)
                }
                let number = token.integer
                try self.nextToken()
                return(VMRegister(rawValue: number + VMRegister.kGPROffset))
        case isIP,isSP,isBP,isXP,isTP:
            }
        }
    private func parseBranch() throws -> ParserStatement
        {
        return(ParserStatement(opcode: .NOP))
        }
    
    private func parseEntry() throws -> ParserStatement
        {
        return(ParserStatement(opcode: .NOP))
        }
    
    private func parseExit() throws -> ParserStatement
        {
        return(ParserStatement(opcode: .NOP))
        }
    }
