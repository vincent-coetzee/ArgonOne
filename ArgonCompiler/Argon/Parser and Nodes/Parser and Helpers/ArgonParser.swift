//
//  ArgonParser.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum Number
    {
    case float(Float)
    case integer(Int)
    case double(Double)
    case byte(UInt8)
    
    public var floatValue:Float
        {
        switch(self)
            {
            case .float(let aFloat):
                return(aFloat)
            default:
                fatalError()
            }
        }
    
    public var integerValue:Int
        {
        switch(self)
            {
            case .integer(let anInt):
                return(anInt)
            default:
                fatalError()
            }
        }
    
    public var byteValue:UInt8
        {
        switch(self)
            {
            case .byte(let anInt):
                return(anInt)
            default:
                fatalError()
            }
        }
    
    public var doubleValue:Double
        {
        switch(self)
            {
            case .double(let anInt):
                return(anInt)
            default:
                fatalError()
            }
        }
    }

public class ArgonParser
    {
    var codeContainers:[ArgonCodeContainer] = []
    var tokenStream:TokenStream!
    var token:Token!
    var scope:ArgonParseScope!
    public let symbolTable = ArgonSymbolTable()
    private var pendingMethodDirectives:ArgonMethodDirective?
    
    init()
        {
        }
    
    public var tokenSourceLocation:SourceLocation
        {
        return(token.location)
        }
    
    public static func newGeneratedName() -> String
        {
        return("__generated__\(Argon.nextCounter)")
        }
    
    public func parse(_ string:String) throws -> ArgonParseModule
        {
        ArgonStandardsNode.initialize()
        tokenStream = TokenStream(source: string)
        token = try tokenStream.nextToken()
        scope = ArgonStandardsNode.shared
        let module = try self.parseModule()
        return(module)
        }
    
    private func nextToken() throws
        {
        token = try tokenStream.nextToken()
        token.print()
        }
    
    private func parseModule() throws -> ArgonParseModule
        {
        if token.isLibrary
            {
            return(try self.parseLibrary())
            }
        else if token.isExecutable
            {
            return(try self.parseExecutable())
            }
        else
            {
            throw(ParseError.libraryOrExecutableExpected)
            }
        }
    
    private func parseLibrary() throws -> ArgonLibraryNode
        {
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        let library = ArgonLibraryNode(name: ArgonName(token.identifier!))
        codeContainers.append(library)
        library.containingScope = scope
        scope = library
        defer
            {
            scope = library.containingScope
            }
        library.enclosingStackFrame = ArgonStackFrame.current()
        let frame = ArgonStackFrame.push(scope:scope)
        frame.name = "LIBRARY \(library.name.string) LINE @ \(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        try self.nextToken()
        try self.parseBraces
            {
            while token.isExport
                {
                try self.parseExport()
                }
            while token.isImport
                {
                try self.parseImport()
                }
            try self.parseEntities()
            }
        return(library)
        }
    
    private func parseExecutable() throws -> ArgonExecutableNode
        {
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        let node = ArgonExecutableNode(name: ArgonName(token.identifier!))
        codeContainers.append(node)
        try self.nextToken()
        try self.parseBraces
            {
            node.containingScope = scope
            let frame = ArgonStackFrame.push(scope:node)
            frame.name = "MAIN EXECUTABLE FRAME"
            node.enclosingStackFrame = ArgonStackFrame.current()
            defer
                {
                ArgonStackFrame.pop()
                }
            scope = node
            defer
                {
                scope = node.containingScope
                }
            try self.parseEntities()
            if !token.isEntryPoint
                {
                throw(ParseError.entryPointExpected)
                }
            try self.nextToken()
            if !token.isLeftPar
                {
                throw(ParseError.leftParExpected)
                }
            try self.nextToken()
            if !token.isRightPar
                {
                throw(ParseError.rightParExpected)
                }
            try self.nextToken()
            let entryPoint = ArgonEntryPointNode(containingScope:scope)
            codeContainers.append(entryPoint)
            let nextFrame = ArgonStackFrame.push(scope:entryPoint)
            nextFrame.name = "ENTRY POINT FRAME"
            entryPoint.enclosingStackFrame = ArgonStackFrame.current()
            entryPoint.containingScope = scope
            scope = entryPoint
            defer
                {
                scope = entryPoint.containingScope
                }
            defer
                {
                ArgonStackFrame.pop()
                }
            try self.parseBraces
                {
                let body = ArgonStatementList()
                while !token.isRightBrace
                    {
                    body.append(try self.parseStatement())
                    }
                entryPoint.statements = body
                }
            node.entryPoint = entryPoint
            }
        return(node)
        }

    private func parseMacro() throws
        {
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        let moduleName = scope.enclosingModule().moduleName
        let node = ArgonMacroNode(containingScope:scope,fullName:moduleName.appending(token.identifier!))
        try self.nextToken()
        try self.parseParenthesis
            {
            var names:[ArgonName] = []
            while !token.isRightPar
                {
                if !token.isIdentifier
                    {
                    throw(ParseError.identifierExpected)
                    }
                let name = ArgonName(token.identifier!)
                names.append(name)
                try self.nextToken()
                }
            node.polymorphicArguments = names.map{ArgonPolymorphicArgument(name: ArgonName($0))}
            }
        scope.add(node: node)
        }
    
    private func parseEntity() throws
        {
        if token.isMacro
            {
            try self.parseMacro()
            }
        else if token.isAt
            {
            try self.nextToken()
            try self.parseMethodDirectives()
            }
        else if token.isImport
            {
            try self.parseImport()
            }
        else if token.isExport
            {
            try self.parseExport()
            }
        else if token.isTraits
            {
            try self.parseTraits()
            }
        else if token.isMethod
            {
            try self.parseMethod()
            }
        else if token.isLet
            {
            scope.add(statement: try self.parseLetStatement())
            }
        else if token.isConstant
            {
            try self.parseConstantStatement()
            }
        else
            {
            throw(ParseError.invalidSyntax)
            }
        }
    
    private func parseEntities() throws
        {
        while !token.isRightBrace && !token.isEntryPoint
            {
            try self.parseEntity()
            }
        }
    
    private func parseParentTraits(inTraits traits:ArgonTraitsNode) throws
        {
        repeat
            {
            try self.nextToken()
            if !token.isIdentifier
                {
                throw(ParseError.traitsParentNameExpected)
                }
            let parentName = token.identifier!
            let parent = scope.resolve(name: ArgonName(parentName))
            guard let aParent = parent else
                {
                throw(ParseError.notTraits(parentName))
                }
            if !aParent.isTraits
                {
                throw(ParseError.notTraits(parentName))
                }
            try self.nextToken()
            if token.isLeftBro
                {
                try self.nextToken()
                let templateName = token.identifier!
                guard let templateType = aParent.resolve(name: ArgonName(templateName)) else
                    {
                    throw(ParseError.invalidTemplateVariable(templateName))
                    }
                if !templateType.isTemplateVariable
                    {
                    throw(ParseError.invalidTemplateVariable(templateName))
                    }
                try self.nextToken()
                if !token.isAssign
                    {
                    throw(ParseError.assignExpected)
                    }
                try self.nextToken()
                let type = try self.parseType()
                let actualType = templateType as! ArgonTypeTemplateNode
                let copy = actualType.makeInstance(with:type)
                copy.definingTraits = traits
                traits.add(typeTemplate: copy)
                try self.nextToken()
                }
            traits.parents.append(aParent as! ArgonTraitsNode)
            }
        while token.isComma
        }
    
    @discardableResult
    private func parseTraits() throws -> ArgonTraitsNode
        {
        let frame = ArgonStackFrame.push(scope:scope)
        defer
            {
            ArgonStackFrame.pop()
            }
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.traitsNameExpected)
            }
        let location = token.location
        let name = token.identifier!
        let fullName = ArgonName(scope.enclosingModule().moduleName.string,name)
        let traits = ArgonTraitsNode(fullName: fullName)
        traits.sourceLocation = location
        traits.fullName = ArgonName(scope.enclosingModule().moduleName.string,name)
        frame.name = "TRAITS \(name) LINE @ \(token.location.lineNumber)"
        traits.enclosingStackFrame = ArgonStackFrame.current()
        traits.containingScope = scope
        scope = traits
        try self.nextToken()
        if token.isLeftBro
            {
            repeat
                {
                try self.nextToken()
                if !token.isIdentifier
                    {
                    throw(ParseError.identifierExpected)
                    }
                let name = token.identifier!
                let item = ArgonTypeTemplateNode(name: ArgonName(name))
                item.traits = ArgonStandardsNode.shared.voidTraits
                item.definingTraits = traits
                try self.nextToken()
                if token.isAssign
                    {
                    guard let definingTraits = scope.resolve(name: ArgonName(name)) else
                        {
                        throw(ParseError.traitsNotDefined(name))
                        }
                    try self.nextToken()
                    let actualType = try self.parseType()
                    guard let sourceTemplate = definingTraits.resolve(name: ArgonName(name)) as? ArgonTypeTemplateNode else
                        {
                        throw(ParseError.invalidType(name))
                        }
                    let instance = sourceTemplate.makeInstance(with: actualType)
                    traits.add(typeTemplate: instance)
                    }
                else
                    {
                    traits.add(typeTemplate: item)
                    }
                if token.isComma
                    {
                    try self.nextToken()
                    }
                }
            while !token.isRightBro
            try self.nextToken()
            }
        if token.isConjunction
            {
            try self.parseParentTraits(inTraits: traits)
            }
        else if traits.parents.count == 0
            {
            traits.parents.append(ArgonStandardsNode.shared.behaviorTraits)
            }
        try self.parseBraces
            {
            try self.parseTraitsSlots(in: traits)
            try self.parseTraitsMethods(in: traits)
            }
        try traits.resolveSlotsAndTypeTemplates()
        scope = traits.containingScope
        scope.add(node: traits)
        return(traits)
        }
    
    private func parseMade(in traits:ArgonTraitsNode) throws
        {
        try self.nextToken()
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        if !token.isRightPar
            {
            throw(ParseError.rightParExpected)
            }
        try self.nextToken()
        let method = ArgonTraitsMadeMethodNode(name: "made")
        method.lineTrace = lineTrace
        method.containingScope = scope
        scope = method
        defer
            {
            scope = method.containingScope
            }
        let frame = ArgonStackFrame.push(scope:method)
        frame.name = "MADE STACKFRAME FOR TRAITS \(traits.name.string)"
        defer
            {
            ArgonStackFrame.pop()
            }
        try parseBraces
            {
            while !token.isRightBrace
                {
                if token.isThis
                    {
                    method.add(statement: try self.parseThisStatement(in: traits))
                    }
                else
                    {
                    method.add(statement: try self.parseStatement())
                    }
                }
            }
        }
        
    private func parseThisStatement(in traits: ArgonTraitsNode) throws -> ArgonMethodStatementNode
        {
        try self.nextToken()
        if !token.isStop
            {
            throw(ParseError.stopExpected)
            }
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        var source:ArgonExpressionNode = ArgonThisNode(traits: traits)
        var lastSlot:ArgonSlotNode?
        while token.isIdentifier
            {
            guard let slot = source.traits.resolve(name: ArgonName(token.identifier!)) as? ArgonSlotNode else
                {
                throw(ParseError.slotExpected)
                }
            lastSlot = slot
            source = ArgonSlotLoadNode(slot: slot,instance: source, traits: source.traits)
            try self.nextToken()
            if token.isStop
                {
                try self.nextToken()
                }
            }
        if !token.isAssign
            {
            throw(ParseError.assignExpected)
            }
        try self.nextToken()
        let value = try self.parseExpression()
        if lastSlot!.traits != value.traits
            {
            throw(ParseError.canNotAssignValueTypeToSlotType(value.traits.name.string,source.traits.name.string))
            }
        return(ArgonSlotAssignmentNode(slot: lastSlot!, of: source, value: value, traits: source.traits))
        }
        
    private func parseTraitsMethods(in traits:ArgonTraitsNode) throws
        {
        var madeDefined = false
        while token.isMethod || token.isMade
            {
            if token.isMade
                {
                if madeDefined
                    {
                    throw(ParseError.madeAlreadyDefined)
                    }
                madeDefined = true
                try self.parseMade(in: traits)
                }
            else
                {
                try self.nextToken()
                if !token.isIdentifier
                    {
                    throw(ParseError.identifierExpected)
                    }
                let methodName = token.identifier!
                try self.nextToken()
                if !token.isLeftPar
                    {
                    throw(ParseError.leftParExpected)
                    }
                let method = ArgonTraitsMethodNode(name: methodName)
                let frame = ArgonStackFrame.push(scope:method)
                frame.name = "TRAITS METHOD \(methodName) LINE @ \(token.location.lineNumber)"
                defer
                    {
                    ArgonStackFrame.pop()
                    }
                method.enclosingStackFrame = ArgonStackFrame.current()
                try self.parseParenthesis
                    {
                    repeat
                        {
                        if !token.isRightPar
                            {
                            if !token.isIdentifier
                                {
                                throw(ParseError.identifierExpected)
                                }
                            let parameterName = token.identifier!
                            try self.nextToken()
                            if !token.isConjunction
                                {
                                throw(ParseError.conjunctionExpected)
                                }
                            try self.nextToken()
                            let type = try self.parseType()
                            let node = ArgonParameterNode(name: ArgonName(parameterName),type:type)
                            node.enclosingStackFrame = ArgonStackFrame.current()
                            method.add(parameter: node)
                            }
                        }
                    while token.isComma
                    }
                var returnType:ArgonType = scope.resolve(name: ArgonName("Argon::Void"))! as! ArgonType
                if token.isResult
                    {
                    try self.nextToken()
                    returnType = try self.parseType()
                    }
                method.returnType = returnType
                method.containingScope = scope
                scope = method
                method.enclosingStackFrame = ArgonStackFrame.current()
                defer
                    {
                    scope = method.containingScope
                    }
                let stackFrame = ArgonStackFrame.push(scope:scope)
                defer
                    {
                    ArgonStackFrame.pop()
                    }
                try self.parseBraces
                    {
                    repeat
                        {
                        let statement = try self.parseStatement()
                        method.add(statement: statement)
                        }
                    while !token.isRightBrace
                    }
                }
            }
        }
        
    private func parseTraitsSlots(in traits: ArgonTraitsNode) throws
        {
        while !token.isRightBrace && !token.isMethod && !token.isMade
            {
            if !token.isIdentifier
                {
                throw(ParseError.traitsSlotNameExpected)
                }
            let slotName = token.identifier!
            if traits.slot(named: ArgonName(slotName)) != nil
                {
                throw(ParseError.duplicateSlotName)
                }
            try self.nextToken()
            var type:ArgonType?
            var initialValue:ArgonExpressionNode?
            if token.isConjunction
                {
                try self.nextToken()
                type = try self.parseType()
                if token.isStop
                    {
                    if !type!.isTraits
                        {
                        throw(ParseError.traitsExpected)
                        }
                    try self.nextToken()
                    if !token.isIdentifier
                        {
                        throw(ParseError.typeTemplateNameExpected)
                        }
                    let typeNode = (type as! ArgonTraitsNode).resolve(name: ArgonName(token.identifier!))
                    if typeNode == nil
                        {
                        throw(ParseError.undefinedTypeTemplate)
                        }
                    try self.nextToken()
                    type = (typeNode as! ArgonType)
                    }
                }
            if token.isAssign
                {
                try self.nextToken()
                initialValue = try self.parseExpression()
                if type != nil
                    {
                    if type!.traits != initialValue!.traits
                        {
                        throw(ParseError.typeMismatch)
                        }
                    }
                else
                    {
                    type = initialValue!.traits
                    }
                }
            let node = ArgonSlotNode(name:slotName,type:type!)
            node.initialValue = initialValue
            node.traits = traits
            traits.add(slot: node)
            }
        }
    
    private func parseType() throws -> ArgonType
        {
        if token.isVoid
            {
            try self.nextToken()
            guard let voidType = scope.resolve(name: ArgonName("Void")) as? ArgonTraitsNode else
                {
                fatalError("Void traits missing and should not be")
                }
            return(voidType)
            }
        //
        // Could be a tuple
        //
        if token.isLeftPar
            {
//            var types:[ArgonType] = []
//            try self.nextToken()
//            while !token.isRightPar
//                {
//                if !token.isIdentifier
//                    {
//                    throw(ParseError.typeExpected)
//                    }
//                let innerType = try self.parseType()
//                types.append(innerType)
//                if token.isComma
//                    {
//                    try self.nextToken()
//                    }
//                }
//            try self.nextToken()
//            let type = scope.resolve(name:ArgonName("Tuple"))!
//            let mainType = ArgonGenericPrimitiveInstanceNode(name: ArgonParser.newGeneratedName(),type:(type as! ArgonPrimitiveNode))
//            mainType.templateTypes = types
            fatalError("Tuples not implemented yet")
            }
        //
        // Some other sort of type
        //
        if !token.isIdentifier
            {
            throw(ParseError.typeExpected)
            }
        let name = token.identifier!
        guard let type = scope.resolve(name:ArgonName(name)) else
            {
            throw(ParseError.typeExpected)
            }
        try self.nextToken()
        if token.isStop
            {
            try self.nextToken()
            if !token.isIdentifier
                {
                throw(ParseError.identifierExpected)
                }
            let templateName = ArgonName(token.identifier!)
            try self.nextToken()
            guard let templateType = type.resolve(name: templateName) else
                {
                throw(ParseError.templateTypeExpected)
                }
            if templateType.isTypeTemplate
                {
                return(templateType as! ArgonType)
                }
            if templateType.isTypeTemplateInstance
                {
                return(templateType as! ArgonType)
                }
            throw(ParseError.invalidType(templateName.string))
            }
        return(type as! ArgonType)
        }
    
    private func parseMethodParameters(into method: ArgonMethodNode) throws
        {
        try self.parseParenthesis
            {
            while !token.isRightPar
                {
                if !token.isIdentifier
                    {
                    throw(ParseError.parameterNameExpected)
                    }
                let parameterName = token.identifier!
                try self.nextToken()
                if !token.isConjunction
                    {
                    throw(ParseError.conjunctionExpected)
                    }
                try self.nextToken()
                if !token.isIdentifier
                    {
                    throw(ParseError.parameterSpecializatonExpected)
                    }
                let type = try self.parseType()
                guard type.isValidSlotType else
                    {
                    throw(ParseError.badParameterSpecializaton)
                    }
                let node = ArgonParameterNode(name:ArgonName(parameterName),type:type)
                node.enclosingStackFrame = ArgonStackFrame.current()
                ArgonStackFrame.current()?.add(parameter: node)
                method.parameters.append(node)
                if token.isComma
                    {
                    try self.nextToken()
                    }
                }
            }
        }
    
    private func parsePrimitive() throws -> Int
        {
        try self.nextToken()
        if !token.isLeftBro
            {
            throw(ParseError.leftBrocketExpected)
            }
        try self.nextToken()
        if !token.isInteger
            {
            throw(ParseError.primitiveNumberExpected)
            }
        let number = token.integer
        try self.nextToken()
        if !token.isRightBro
            {
            throw(ParseError.rightBrocketExpected)
            }
        try self.nextToken()
        return(number)
        }
    
    private func parseMethod() throws
        {
        let line = token.location.lineNumber
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.methodNameExpected)
            }
        let methodName = token.identifier!
        let location = token.location
        let genericMethod = scope.resolve(name: ArgonName(methodName))
        var generic:ArgonGenericMethodNode
        var isNew = false
        if genericMethod == nil
            {
            generic = ArgonGenericMethodNode(name: methodName)
            generic.fullName = ArgonName(scope.enclosingModule().moduleName.string,methodName)
            scope.add(node: generic)
            isNew = true
            }
        else
            {
            if genericMethod is ArgonGenericMethodNode
                {
                generic = genericMethod as! ArgonGenericMethodNode
                }
            else
                {
                throw(ParseError.methodNameExpected)
                }
            }
        if pendingMethodDirectives != nil
            {
            generic.directives = pendingMethodDirectives!
            pendingMethodDirectives = nil
            }
        var method:ArgonMethodNode
        generic.moduleName = scope.enclosingModule().moduleName
        method = ArgonMethodNode(name:methodName)
        codeContainers.append(method)
        method.sourceLocation = location
        try self.nextToken()
        let frame = ArgonStackFrame.push(scope:method)
        frame.name = "METHOD \(methodName) LINE @\(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        method.enclosingStackFrame = frame
        try self.parseMethodParameters(into: method)
        generic.parameterCount = method.parameters.count
        method.containingScope = scope
        scope = method
        defer
            {
            scope = method.containingScope
            }
        var returnType:ArgonType = scope.resolve(name: ArgonName("Void"))! as! ArgonType
        if token.isResult
            {
            try self.nextToken()
            returnType = try self.parseType()
            }
        method.returnType = returnType
        generic.add(instance: method)
        try self.parseBraces
            {
            if token.isPrimitive
                {
                let number = try self.parsePrimitive()
                method.isPrimitive = true
                method.primitiveNumber = number
                generic.isPrimitive = true
                }
            else
                {
                method.statements = try self.parseMethodBody()
                }
            }
        }
    
    private func parseStatement() throws -> ArgonMethodStatementNode
        {
        if token.isLet
            {
            return(try parseLetStatement())
            }
        else if token.isIf
            {
            return(try parseIfStatement())
            }
        else if token.isReturn
            {
            return(try parseReturnStatement())
            }
        else if token.isWhile
            {
            return(try parseWhileStatement())
            }
        else if token.isFor
            {
            return(try parseForLoopStatement())
            }
        else if token.isSwitch
            {
            return(try parseSwitchStatement())
            }
        else if token.isWith
            {
            return(try parseWithStatement())
            }
        else if token.isNextMethod
            {
            return(try parseNextMethodStatement())
            }
        else if token.isResume
            {
            return(try parseResumeStatement())
            }
        else if token.isSignal
            {
            return(try parseSignalStatement())
            }
        else if token.isSpawn
            {
            return(try parseSpawnStatement())
            }
        else if token.isIdentifier
            {
            return(try parseIdentifierBasedStatement())
            }
        throw(ParseError.invalidSyntax)
        }
    
    private func parseResumeStatement() throws -> ArgonResumeStatementNode
        {
        try self.nextToken()
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        if !token.isRightPar
            {
            throw(ParseError.rightParExpected)
            }
        try self.nextToken()
        return(ArgonResumeStatementNode())
        }
    
    private func parseSignalStatement() throws -> ArgonSignalStatementNode
        {
        try self.nextToken()
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        var symbol:Symbol?
        try self.parseParenthesis
            {
            if !token.isSymbol
                {
                throw(ParseError.symbolExpected)
                }
            symbol = Symbol.symbol(token.symbol)
            try self.nextToken()
            }
        return(ArgonSignalStatementNode(symbol:symbol!))
        }
    
    private func parseHandlerStatement() throws -> ArgonHandlerStatementNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        try self.nextToken()
        var conditionName:ArgonName = ArgonName()
        var conditionSymbol:Symbol?
        let location = token.location
        var node:ArgonHandlerStatementNode?
        try self.parseParenthesis
            {
            if !token.isSymbol
                {
                throw(ParseError.symbolExpected)
                }
            conditionSymbol = Symbol.symbol(token.symbol)
            try self.nextToken()
            node = ArgonHandlerStatementNode(containingScope:scope,conditionSymbol:conditionSymbol!)
            scope.enclosingMethod()?.add(handler:node!)
            }
        if !token.isLeftBrace
            {
            throw(ParseError.leftBraceExpected)
            }
        node?.lineTrace = lineTrace
        scope = node
        let frame = ArgonStackFrame.push(scope:node!)
        frame.name = "HANDLER LINE @ \(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        node!.enclosingStackFrame = frame
        defer
            {
            scope = node!.containingScope
            }
        try self.parseBraces
            {
            while !token.isRightBrace
                {
                let statement = try self.parseStatement()
                node!.add(statement: statement)
                }
            }
        return(node!)
        }
    
    private func parseSpawnStatement() throws -> ArgonSpawnStatementNode
        {
        try self.nextToken()
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        var node:ArgonSpawnStatementNode?
        if token.isLeftBrace
                {
                let closure = try self.parseClosure()
                node = ArgonSpawnStatementNode(closure: closure)
                }
            else if token.isIdentifier
                {
                let name = token!.identifier
                try self.nextToken()
                guard let local = scope.resolve(name: ArgonName(name)) as? ArgonClosureVariableNode else
                    {
                    throw(ParseError.closureOrClosureVariableExpected)
                    }
                node = try ArgonSpawnStatementNode(localContainingClosure: local)
                }
            else
                {
                throw(ParseError.closureOrClosureVariableExpected)
                }
        node!.lineTrace = lineTrace
        let parameters = try self.parseClosureParameterValues(closure: node!.closure)
        try self.nextToken()
        node!.arguments = parameters
        for index in 0..<node!.closure.inductionVariableCount
            {
            if node!.closure.inductionVariables[index].traits != parameters[index].traits
                {
                throw(ParseError.typeMismatch)
                }
            }
        return(node!)
        }
        
    private func parseWithStatement() throws -> ArgonWithStatementNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        try self.nextToken()
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        let targetExpression = try self.parseExpression()
        if !token.isRightPar
            {
            throw(ParseError.rightParExpected)
            }
        try self.nextToken()
        let withNode = ArgonWithStatementNode(containingScope:scope,target: targetExpression)
        withNode.lineTrace = lineTrace
        scope = withNode
        defer
            {
            scope = withNode.containingScope
            }
        try self.parseBraces
            {
            while !token.isRightBrace
                {
                withNode.add(statement: try self.parseStatement())
                }
            }
        return(withNode)
        }
        
    private func parseNextMethodStatement() throws -> ArgonNextMethodStatementNode
        {
        try self.nextToken()
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        guard let currentMethod = scope.enclosingMethod() else
            {
            throw(ParseError.nextMethodNotInMethod)
            }
        var parameters:[ArgonParameterNode] = []
        try self.parseParenthesis
            {
            for parameter in currentMethod.parameters
                {
                if !token.isIdentifier
                    {
                    throw(ParseError.identifierExpected)
                    }
                let parameterName = ArgonName(token.identifier!)
                if parameter.name != parameterName
                    {
                    throw(ParseError.invalidParameter)
                    }
                parameters.append(parameter)
                try self.nextToken()
                if token.isComma
                    {
                    try self.nextToken()
                    }
                }
            }
        let statement = ArgonNextMethodStatementNode(parameters: parameters,method:currentMethod)
        statement.lineTrace = lineTrace
        return(statement)
        }
        
    private func parseSwitchStatement() throws -> ArgonSwitchStatementNode
        {
        try self.nextToken()
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        let switchExpression = try self.parseExpression()
        let switchNode = ArgonSwitchStatementNode(containingScope: scope, expression: switchExpression)
        switchNode.lineTrace = lineTrace
        switchNode.enclosingStackFrame = ArgonStackFrame.current()!
        let frame = ArgonStackFrame.push(scope:switchNode)
        frame.name = "SWITCH STATEMENT @ LINE \(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        scope = switchNode
        defer
            {
            scope = switchNode.containingScope
            }
        if !token.isRightPar
            {
            throw(ParseError.rightParExpected)
            }
        try self.nextToken()
        var otherwiseUsed = false
        try self.parseBraces
            {
            repeat
                {
                if !token.isCase && !token.isOtherwise
                    {
                    throw(ParseError.caseExpected)
                    }
                let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
                let isOtherwise = token.isOtherwise
                try self.nextToken()
                var caseNode:ArgonCaseStatementNode?
                var otherwise:ArgonCompoundMethodStatementNode?
                if isOtherwise
                    {
                    if otherwiseUsed
                        {
                        throw(ParseError.onlyOneOtherwise)
                        }
                    otherwiseUsed = true
                    otherwise = ArgonCompoundMethodStatementNode(containingScope: scope)
                    otherwise!.lineTrace = lineTrace
                    switchNode.add(otherwise: otherwise!)
                    scope = otherwise
                    }
                else
                    {
                    let caseExpression = try self.parseExpression()
                    if caseExpression.traits != switchExpression.traits
                        {
                        throw(ParseError.caseTypeDiffersFromSwitchType)
                        }
                    caseNode = ArgonCaseStatementNode(containingScope: scope, expression: caseExpression)
                    caseNode!.lineTrace = lineTrace
                    switchNode.add(case: caseNode!)
                    scope = caseNode
                    }
                if !token.isColon
                    {
                    throw(ParseError.colonExpected)
                    }
                try self.nextToken()
                repeat
                    {
                    if !token.isRightBrace
                        {
                        let statement = try self.parseStatement()
                        if isOtherwise
                            {
                            otherwise?.add(statement: statement)
                            }
                        else
                            {
                            caseNode?.add(statement: statement)
                            }
                        }
                    }
                while !token.isCase && !token.isOtherwise && !token.isRightBrace
                scope = scope.enclosingScope()
                }
            while !token.isRightBrace
            }
        return(switchNode)
        }
    
    private func parseMethodBody() throws -> ArgonStatementList
        {
        let body = ArgonStatementList()
        var returnFound = false
        while !token.isRightBrace
            {
            if returnFound
                {
                throw(ParseError.statementsAfterReturn)
                }
            let statement = try self.parseStatement()
            body.append(statement)
            if statement.isReturnStatement
                {
                returnFound = true
                }
            }
        return(body)
        }
    
    private func parseMethodDirectives() throws
        {
        try self.parseParenthesis
            {
            var directives:ArgonMethodDirective = []
            while !token.isRightPar
                {
                if !token.isDirective
                    {
                    throw(ParseError.directiveExpected)
                    }
                switch(token.keyword!)
                    {
                    case .system:
                        directives = directives.union(ArgonMethodDirective.system)
                    case .dynamic:
                        directives = directives.union(ArgonMethodDirective.dynamic)
                    case .inline:
                        directives = directives.union(ArgonMethodDirective.inline)
                    case .static:
                        directives = directives.union(ArgonMethodDirective.static)
                    default:
                         throw(ParseError.invalidDirective)
                    }
                try self.nextToken()
                if token.isComma
                    {
                    try self.nextToken()
                    }
                }
            self.pendingMethodDirectives = directives
            }
        }
    
    private func parseMethodInvocationStatement(method:ArgonGenericMethodNode) throws -> ArgonMethodInvocationNode
        {
        if !token.isLeftPar
            {
            throw(ParseError.methodPatternExpected)
            }
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        try self.nextToken()
        var nodes:[ArgonParameterValueNode] = []
        let expectedParameterNames = method.parameters.map{$0.name}
        var index = 0
        while !token.isRightPar
            {

            if !token.isIdentifier
                {
                throw(ParseError.identifierExpected)
                }
            let name = ArgonName(token.identifier!)
            if expectedParameterNames[index] != name
                {
                throw(ParseError.parameterWithNameExpected(expectedParameterNames[index].string))
                }
            try self.nextToken()
            if !token.isConjunction
                {
                throw(ParseError.identifierExpected)
                }
            try self.nextToken()
            let value = try self.parseExpression()
            nodes.append(ArgonParameterValueNode(name: name,traits:value.traits,value:value))
            if token.isComma
                {
                try self.nextToken()
                }
            index += 1
            if index >= expectedParameterNames.count
                {
                index = expectedParameterNames.count - 1
                }
            }
        try self.nextToken()
        if !method.allowsAnyArity
            {
            if nodes.count != method.arity
                {
                throw(ParseError.invalidNumberOfParameters)
                }
            }
        let nodeTraits = nodes.map {$0.traits}
        if !method.canDispatch(forTraits: nodeTraits)
            {
            throw(ParseError.noSpecializationOfGenericMethodFits)
            }
        let node = ArgonMethodInvocationNode(genericMethod:method,arguments: nodes)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseMethodInvocationExpression(method:ArgonGenericMethodNode) throws -> ArgonMethodValueNode
        {
        if !token.isLeftPar
            {
            throw(ParseError.methodPatternExpected)
            }
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        try self.nextToken()
        var nodes:[ArgonParameterValueNode] = []
        let expectedParameterNames = method.parameters.map{$0.name}
        var index = 0
        let expectsNames = method.name.string != "make"
        while !token.isRightPar
            {
            var name:ArgonName
            if expectsNames
                {
                if !token.isIdentifier
                    {
                    throw(ParseError.identifierExpected)
                    }
                name = ArgonName(token.identifier!)
                if expectedParameterNames[index] != name
                    {
                    throw(ParseError.parameterWithNameExpected(expectedParameterNames[index].string))
                    }
                try self.nextToken()
                if !token.isConjunction
                    {
                    throw(ParseError.identifierExpected)
                    }
                try self.nextToken()
                }
            else
                {
                name = ArgonName()
                }
            let value = try self.parseExpression()
            nodes.append(ArgonParameterValueNode(name: name,traits:value.traits,value:value))
            if token.isComma
                {
                try self.nextToken()
                }
            index += 1
            if index >= expectedParameterNames.count
                {
                index = expectedParameterNames.count - 1
                }
            }
        try self.nextToken()
        if !method.allowsAnyArity
            {
            if nodes.count != method.arity
                {
                throw(ParseError.invalidNumberOfParameters)
                }
            }
        let nodeTraits = nodes.map {$0.traits}
        if !method.canDispatch(forTraits: nodeTraits)
            {
            throw(ParseError.noSpecializationOfGenericMethodFits)
            }
        let node = ArgonMethodValueNode(genericMethod:method,arguments: nodes)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseStoredValueAssignment(storedValue: ArgonStoredValueNode) throws -> ArgonMethodStatementNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if storedValue.isReadOnly
            {
            throw(ParseError.readOnlyValuesCanNotBeLValues)
            }
        if storedValue.isParameter
            {
            throw(ParseError.parametersCanNotBeLValues)
            }
        if token.isStop
            {
            return(try self.parseSlotAssignment(storedValue: storedValue))
            }
        if !token.isAssign
            {
            throw(ParseError.assignExpected)
            }
        try self.nextToken()
        let value = try self.parseExpression()
        if !value.traits.unify(with: storedValue.traits)
            {
            throw(ParseError.invalidType(storedValue.name.string))
            }
        let node = ArgonAssignmentStatementNode(target: storedValue,source: value)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseSlotAssignmentInWith(slot: ArgonSlotNode) throws -> ArgonSlotAssignmentNode
        {
        guard let withNode = scope.enclosingWith() else
            {
            throw(ParseError.slotCanNotBeAccessedHere)
            }
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        var theSlot:ArgonSlotNode = slot
        var source:ArgonExpressionNode = withNode.targetExpression
        while true
            {
            if token.isStop
                {
                source = ArgonSlotLoadNode(slot: theSlot, instance: source,traits: source.traits)
                try self.nextToken()
                if token.isIdentifier
                    {
                    if let nextSlot = source.traits.slot(named: ArgonName(token.identifier!))
                        {
                        theSlot = nextSlot
                        }
                    }
                }
            else if token.isAssign
                {
                try self.nextToken()
                let value = try self.parseExpression()
                if value.traits != theSlot.traits
                    {
                    throw(ParseError.expectedExpressionOfType(theSlot.traits.name.string))
                    }
                let node = ArgonSlotAssignmentNode(slot: theSlot,of: source,value: value,traits: source.traits)
                node.lineTrace = lineTrace
                return(node)
                }
            }
        }
    
    private func parseVectorElementAssignment(storedValue: ArgonStoredValueNode) throws -> ArgonVectorElementAssignmentNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if !storedValue.traits.inherits(from: ArgonStandardsNode.shared.vectorTraits)
            {
            throw(ParseError.collectionExpected(storedValue.traits.name.string))
            }
        try self.nextToken()
        var index = try self.parseExpression()
        if !index.traits.inherits(from: ArgonStandardsNode.shared.integerTraits)
            {
            throw(ParseError.invalidIndexType(index.traits.name.string))
            }
        index = ArgonArithmeticExpressionNode(index,.mul,ArgonConstantNode(integer: 8))
        if !token.isRightBra
            {
            throw(ParseError.rightBraExpected)
            }
        try self.nextToken()
        if !token.isAssign
            {
            throw(ParseError.assignExpected)
            }
        try self.nextToken()
        let value = try self.parseExpression()
        let node = ArgonVectorElementAssignmentNode(vector: storedValue,index: index,value: value)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseIdentifierBasedStatement() throws -> ArgonMethodStatementNode
        {
        let name = token.identifier!
        let item = scope.resolve(name: ArgonName(name))
        try self.nextToken()
        switch(item)
            {
            case is ArgonGenericMethodNode:
                return(try self.parseMethodInvocationStatement(method: item as! ArgonGenericMethodNode))
            case is ArgonSlotNode:
                return(try self.parseSlotAssignmentInWith(slot: item as! ArgonSlotNode))
            case is ArgonStoredValueNode:
                if (item as! ArgonStoredValueNode).containsClosure
                    {
                    return(try self.parseClosureCall(closure: (item as! ArgonClosureVariableNode).closure))
                    }
                if item != nil && item!.traits.inherits(from:ArgonStandardsNode.shared.vectorTraits) && token.isLeftBra
                    {
                    return(try self.parseVectorElementAssignment(storedValue: item as! ArgonStoredValueNode))
                    }
                return(try self.parseStoredValueAssignment(storedValue: item as! ArgonStoredValueNode))
            default:
                throw(ParseError.undefinedSymbol(name))
            }
        }
    
    private func parseClosureParameterValues(closure:ArgonClosureNode) throws -> [ArgonParameterValueNode]
        {
        var parameters:[ArgonParameterValueNode] = []
        
        try self.parseParenthesis
            {
            var index = 0
            while !token.isRightPar
                {
                if index >= closure.inductionVariableCount
                    {
                    throw(ParseError.invalidNumberOfArguments)
                    }
                if !token.isIdentifier
                    {
                    throw(ParseError.identifierExpected)
                    }
                let name = ArgonName(token.identifier!)
                try self.nextToken()
                if !token.isConjunction
                    {
                    throw(ParseError.conjunctionExpected)
                    }
                try self.nextToken()
                let value = try self.parseExpression()
                let closureParameter = closure.inductionVariable(at: index)
                if closureParameter == nil
                    {
                    throw(ParseError.invalidNumberOfArguments)
                    }
                if value.traits != closureParameter!.traits
                    {
                    throw(ParseError.typeMismatch)
                    }
                parameters.append(ArgonParameterValueNode(name: name, traits: value.traits, value: value))
                index += 1
                }
            }
        return(parameters)
        }
    
    private func parseClosureCall(closure:ArgonClosureNode) throws -> ArgonClosureCallNode
        {
        let parameters = try self.parseClosureParameterValues(closure:closure)
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if parameters.count != closure.inductionVariables.count
            {
            throw(ParseError.invalidNumberOfArguments)
            }
        let node = ArgonClosureCallNode(lhs: nil,closure: closure,arguments: parameters)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseClosureCallExpression(closure:ArgonClosureNode) throws -> ArgonClosureInvocationNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        let parameters = try self.parseClosureParameterValues(closure:closure)
        if parameters.count != closure.inductionVariables.count
            {
            throw(ParseError.invalidNumberOfArguments)
            }
        let node = ArgonClosureInvocationNode(closure: closure,arguments: parameters)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseSlotLoad(storedValue inInstance:ArgonExpressionNode) throws -> ArgonSlotLoadNode
        {
        var instance = inInstance
        if !token.isStop
            {
            throw(ParseError.stopExpected)
            }
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        var node:ArgonSlotLoadNode?
        while token.isIdentifier
            {
            let traits = instance.traits
            let name = token.identifier!
            try self.nextToken()
            guard let slot = traits.slot(named: ArgonName(name)) else
                {
                throw(ParseError.accessorExpected)
                }
            node = ArgonSlotLoadNode(slot:slot,instance:instance,traits:traits)
            if token.isStop
                {
                try self.nextToken()
                instance = node!
                }
            }
        return(node!)
        }
    
    private func parseSlotAssignment(storedValue: ArgonStoredValueNode) throws -> ArgonSlotAssignmentNode
        {
        try self.nextToken()
        var source:ArgonExpressionNode = storedValue
        repeat
            {
            let name = token.identifier!
            let traits = source.traits
            guard let slot = traits.slot(named: ArgonName(name)) else
                {
                throw(ParseError.undefinedSymbol(name))
                }
            try self.nextToken()
            if token.isStop
                {
                source = ArgonSlotLoadNode(slot: slot, instance: source,traits:traits)
                try self.nextToken()
                }
            else if token.isAssign
                {
                try self.nextToken()
                let value = try self.parseExpression()
                if value.traits != slot.traits
                    {
                    throw(ParseError.invalidType(""))
                    }
                return(ArgonSlotAssignmentNode(slot: slot,of: source,value: value,traits:traits))
                }
            }
        while true
        }
    
    private func parseForLoopStatement() throws -> ArgonForStatementNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        let forNode = ArgonForStatementNode(containingScope:scope)
        forNode.lineTrace = lineTrace
        forNode.containingScope = scope
        scope = forNode
        defer
            {
            scope = forNode.containingScope
            }
        let frame = ArgonStackFrame.push(scope:forNode)
        frame.name = "FOR LOOP LINE @ \(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        forNode.enclosingStackFrame = frame
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        let name = token.identifier!
        try self.nextToken()
        if !token.isIn
            {
            throw(ParseError.inExpected)
            }
        try self.nextToken()
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        if !token.isFrom
            {
            throw(ParseError.fromExpected)
            }
        try self.nextToken()
        let lowerBound = try self.parseExpression()
        if !token.isComma
            {
            throw(ParseError.commaExpected)
            }
        try self.nextToken()
        if !token.isTo
            {
            throw(ParseError.toExpected)
            }
        try self.nextToken()
        let upperBound = try self.parseExpression()
        if upperBound.traits != lowerBound.traits
            {
            throw(ParseError.toTypeMustMatchFromType)
            }
        var step:ArgonExpressionNode = ArgonConstantNode(integer: 1)
        if token.isComma
            {
            try self.nextToken()
            if !token.isBy
                {
                throw(ParseError.byExpected)
                }
            try self.nextToken()
            step = try self.parseExpression()
            if step.traits != lowerBound.traits
                {
                throw(ParseError.stepTypeMustMatchBoundTypes)
                }
            if !token.isRightPar
                {
                throw(ParseError.rightParExpected)
                }
            try self.nextToken()
            let inductionVariable = ArgonInductionVariableNode(name: ArgonName(name),traits: lowerBound.traits,initialValue: nil)
            inductionVariable.symbolTableEntry = symbolTable.add(variable: inductionVariable, at: scope.scopeName() + name)
            forNode.inductionVariable = inductionVariable
            forNode.lowerBound(lowerBound,upperBound:upperBound,step:step)
            scope.add(variable: inductionVariable)
            }
        try self.parseBraces
            {
            repeat
                {
                forNode.add(statement: try self.parseStatement())
                }
            while !token.isRightBrace
            }
        return(forNode)
        }
    
    private func parseClosure() throws -> ArgonClosureNode
        {
        let moduleName = scope.enclosingModule().moduleName
        let closure = ArgonClosureNode(containingScope: scope,moduleName:moduleName)
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        closure.lineTrace = lineTrace
        scope = closure
        defer
            {
            scope = closure.containingScope
            }
        let frame = ArgonStackFrame.push(scope:closure)
        frame.name = "CLOSURE LINE @ \(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        closure.enclosingStackFrame = frame
        try self.nextToken()
        if !token.isIn
            {
            throw(ParseError.inExpected)
            }
        try self.nextToken()
        try self.parseParenthesis
            {
            if token.isVoid
                {
                try self.nextToken()
                }
            else
                {
                while !token.isRightPar && !token.isVoid
                    {
                    if !token.isIdentifier
                        {
                        throw(ParseError.identifierExpected)
                        }
                    let name = token.identifier
                    try self.nextToken()
                    if !token.isConjunction
                        {
                        throw(ParseError.conjunctionExpected)
                        }
                    try self.nextToken()
                    let type = try self.parseType()
                    let induction = ArgonParameterNode(name:ArgonName(name),type:type)
                    induction.enclosingStackFrame = ArgonStackFrame.current()
                    closure.add(induction: induction)
                    if token.isComma
                        {
                        try self.nextToken()
                        }
                    }
                }
            }
        var resultType:ArgonType = scope.resolve(name: ArgonName("Void")) as! ArgonType
        if token.isResult
            {
            try self.nextToken()
            resultType = try self.parseType()
            }
        closure.resultType = resultType
        while !token.isRightBrace
            {
            let statement = try self.parseStatement()
            closure.add(statement: statement)
            }
        try self.nextToken()
        codeContainers.append(closure)
        return(closure)
        }
        
    private func parseTupleTerm() throws -> ArgonExpressionNode
        {
        try self.nextToken()
        var terms:[ArgonExpressionNode] = []
        while !token.isRightPar
            {
            terms.append(try self.parseExpression())
            }
        try self.nextToken()
        let node = ArgonTupleExpressionNode(terms:terms)
        return(node)
        }
    
    private func parseIdentifierBasedTerm() throws -> ArgonExpressionNode
        {
//        print(#function)
        let name = token.identifier!
        try self.nextToken()
        if token.isLeftBra
            {
            guard let collection = scope.resolve(name: ArgonName(name)) else
                {
                throw(ParseError.undefinedSymbol(name))
                }
            try self.nextToken()
            guard collection.traits.inherits(from: ArgonStandardsNode.shared.vectorTraits) else
                {
                throw(ParseError.collectionExpected(name))
                }
            let index = try self.parseExpression()
            if !token.isRightBra
                {
                throw(ParseError.rightBraExpected)
                }
            try self.nextToken()
            return(ArgonVectorElementNode(vector:collection as! ArgonExpressionNode,index:index))
            }
        else if token.isLeftPar
            {
            guard let scopeItem = scope.resolve(name: ArgonName(name)) else
                {
                throw(ParseError.undefinedSymbol(name))
                }
            if name != "make"
                {
                if scopeItem is ArgonGenericMethodNode
                    {
                    return(try self.parseMethodInvocationExpression(method: scopeItem as! ArgonGenericMethodNode))
                    }
                else if scopeItem.traits == ArgonStandardsNode.shared.closureTraits && scopeItem is ArgonClosureVariableNode
                    {
                    let closure = (scopeItem as! ArgonClosureVariableNode).closure
                    return(try self.parseClosureCallExpression(closure: closure))
                    }
                else if scopeItem.isClosure
                    {
                    let closure = (scopeItem as! ArgonClosureVariableNode).closure
                    return(try self.parseClosureCallExpression(closure: closure))
                    }
                }
            try self.nextToken()
            var parts:[ArgonExpressionNode] = []
            repeat
                {
                if token.isComma
                    {
                    try self.nextToken()
                    }
                let expression = try self.parseExpression()
                parts.append(expression)
                }
            while token.isComma
            if !token.isRightPar
                {
                throw(ParseError.rightParExpected)
                }
            try self.nextToken()
            if name == "make"
                {
                if parts.count < 1 || !parts[0].isTraits
                    {
                    throw(ParseError.makeExpectsTraitsParameters)
                    }
                return(ArgonMakeInvocationNode(arguments:parts))
                }
            
            else if scopeItem.isStoredValue
                {
                return(scopeItem as! ArgonStoredValueNode)
                }
            }
        else
            {
            let item = scope.resolve(name: ArgonName(name))
            if item is ArgonSlotNode
                {
                guard let with = scope.enclosingWith() else
                    {
                    throw(ParseError.slotCanNotBeAccessedHere)
                    }
                let instance = with.instanceExpression
                return(ArgonSlotLoadNode(slot:item as! ArgonSlotNode,instance: instance,traits: instance.traits))
                }
            else if item is ArgonStoredValueNode
                {
                let storedValue = item as! ArgonStoredValueNode
                if token.isStop
                    {
                    return(try self.parseSlotLoad(storedValue: storedValue))
                    }
                return(storedValue)
                }
            if item is ArgonConstantNode
                {
                return(item as! ArgonConstantNode)
                }
            if item is ArgonTraitsNode
                {
                return(item as! ArgonTraitsNode)
                }
            }
        throw(ParseError.undefinedSymbol(name))
        }
    
    private func parseTerm() throws -> ArgonExpressionNode
        {
//        print(#function)
        if token.isString
            {
            let string = token.string
            try self.nextToken()
            return(ArgonConstantNode(string:string))
            }
        else if (token.isTrue || token.isFalse)
            {
            let boolean = token.boolean
            try self.nextToken()
            return(ArgonConstantNode(boolean:boolean))
            }
        else if token.isInteger
            {
            let intValue = token.integer
            try self.nextToken()
            return(ArgonConstantNode(integer:intValue))
            }
        else if token.isFloat
            {
            let float = token.float
            try self.nextToken()
            return(ArgonConstantNode(float:float))
            }
        else if token.isSymbol
            {
            let symbol = token.symbol
            try self.nextToken()
            if symbol == "#true" || symbol == "#false"
                {
                return(ArgonConstantNode(boolean:symbol == "#true"))
                }
            return(ArgonConstantNode(symbol:Symbol.symbol(symbol)))
            }
        else if token.isIdentifier
            {
            return(try parseIdentifierBasedTerm())
            }
        else if token.isLeftPar
            {
            return(try parseTupleTerm())
            }
        else if token.isLeftBrace
            {
            return(try self.parseClosure())
            }
        else
            {
            return(ArgonConstantNode(void:true))
            }
        }
    
    private func parseBracketedExpression() throws -> ArgonExpressionNode
        {
        if token.isLeftPar
            {
            try self.nextToken()
            let expression = try self.parseExpression()
            if !token.isRightPar
                {
                throw(ParseError.rightParExpected)
                }
            try self.nextToken()
            return(expression)
            }
        else
            {
            return(try self.parseTerm())
            }
        }
    
    private func parseComparisonExpression() throws -> ArgonExpressionNode
        {
        let lhs = try self.parseBracketedExpression()
        if token.isConditional
            {
            let operation = token.type
            try self.nextToken()
            let rhs = try self.parseBracketedExpression()
            return(ArgonRelationExpressionNode(lhs,operation,rhs))
            }
        else
            {
            return(lhs)
            }
        }
    
    private func parseMulExpression() throws -> ArgonExpressionNode
        {
        var expression = try self.parseComparisonExpression()
        while token.isMul || token.isDiv
            {
            let tokenType = token.type
            try self.nextToken()
            expression = ArgonArithmeticExpressionNode(expression,tokenType,try self.parseComparisonExpression())
            }
        return(expression)
        }
    
    private func parseAddExpression() throws -> ArgonExpressionNode
        {
        var expression = try self.parseMulExpression()
        while token.isPlus || token.isMinus || token.isMod
            {
            let tokenType = token.type
            try self.nextToken()
            let rhs = try self.parseMulExpression()
            expression = ArgonArithmeticExpressionNode(expression,tokenType,rhs)
            }
        return(expression)
        }
    
    private func parseBitLogicExpression() throws -> ArgonExpressionNode
        {
        var expression = try self.parseAddExpression()
        while token.isBitAnd || token.isBitOr || token.isBitNot || token.isBitXor
            {
            let tokenType = token.type
            try self.nextToken()
            expression = ArgonArithmeticExpressionNode(expression,tokenType,try self.parseAddExpression())
            }
        return(expression)
        }
    
    private func parseBooleanExpression() throws -> ArgonExpressionNode
        {
        var expression = try self.parseBitLogicExpression()
        while token.isAnd || token.isOr
            {
            let tokenType = token.type
            try self.nextToken()
            expression = ArgonBooleanExpressionNode(expression,tokenType,try self.parseBitLogicExpression())
            }
        return(expression)
        }
        
    private func parseExpression() throws -> ArgonExpressionNode
        {
        if token.isMinus || token.isNot
            {
            let tokenType = token.type
            try self.nextToken()
            let expression = try self.parseBooleanExpression()
            if expression.traits != ArgonStandardsNode.shared.booleanTraits && tokenType == .not
                {
                throw(ParseError.booleanExpressionExpected)
                }
            return(ArgonUnaryOperationExpression(operation:tokenType,expression:expression))
            }
        else
            {
            let expression = try self.parseBooleanExpression()
            return(expression)
            }
        }
    
    private func parseConstantStatement() throws
        {
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        let name = ArgonName(token.identifier!)
        try self.nextToken()
        if !token.isAssign
            {
            throw(ParseError.assignExpected)
            }
        try self.nextToken()
        if !(token.isSymbol || token.isString || token.isNumber || token.isBoolean)
            {
            throw(ParseError.constantValueExpected)
            }
        var node:ArgonNamedConstantNode?
        let fullName = ArgonName(scope.enclosingModule().moduleName.string,name.string)
        if token.isSymbol
            {
            node = ArgonNamedConstantNode(fullName:fullName,symbol:Symbol.symbol(token.symbol))
            }
        else if token.isString
            {
            node = ArgonNamedConstantNode(fullName:fullName,string:token.string)
            }
        else if token.isBoolean
            {
            node = ArgonNamedConstantNode(fullName:fullName,boolean:token.symbol == "#true")
            }
        else if token.isFloat
            {
            node = ArgonNamedConstantNode(fullName:fullName,float:token.float)
            }
        else if token.isInteger
            {
            node = ArgonNamedConstantNode(fullName:fullName,integer:token.integer)
            }
        else
            {
            throw(ParseError.invalidType(""))
            }
        try self.nextToken()
        scope.add(constant: node!)
        node!.symbolTableEntry = symbolTable.add(constant: node!, at: scope.scopeName() + node!.name)
        }
    
    private func parseLetStatement() throws -> ArgonMethodStatementNode
        {
        try self.nextToken()
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if token.isHandler
            {
            return(try self.parseHandlerStatement())
            }
        if !token.isIdentifier
            {
            throw(ParseError.temporaryNameExpected)
            }
        let nameOfVar = token.identifier!
        let location = token.location
        try self.nextToken()
        var type:ArgonType? = nil
        if token.isConjunction
            {
            try self.nextToken()
            type = try self.parseType()
            }
        if !token.isAssign
            {
            throw(ParseError.assignmentExpected)
            }
        try self.nextToken()
        let value = try self.parseExpression()
        let varName = ArgonName(nameOfVar)
        let traits = type != nil ? type!.traits : value.traits
        var local:ArgonVariableNode
        if value.traits.name.string == "Closure"
            {
            local = ArgonClosureVariableNode(name: varName,closure: value as! ArgonClosureNode)
            }
        else if scope.isGlobalScope()
            {
            local = ArgonGlobalVariableNode(name: varName,traits: traits,initialValue: value)
            }
        else
            {
            local = ArgonLocalVariableNode(name: varName,traits: traits,initialValue: value)
            }
        local.sourceLocation = location
        ArgonStackFrame.current()?.add(variable: local)
        local.symbolTableEntry = symbolTable.add(variable: local,at: scope.scopeName() + local.name)
        local.scopedName = ArgonName(scope.enclosingModule().moduleName.string,nameOfVar)
        let node = ArgonVariableInitializationStatementNode(name: varName, traits: traits, value: value, variable: local)
        node.lineTrace = lineTrace
        return(node)
        }
    
    private func parseIntegerExpression() throws -> ArgonExpressionNode
        {
        return(ArgonExpressionNode())
        }
    
    private func parseStringExpression() throws -> ArgonExpressionNode
        {
        return(ArgonExpressionNode())
        }
    
    private func parseDoubleExpression() throws -> ArgonExpressionNode
        {
        return(ArgonExpressionNode())
        }
    
    private func parseDateExpression() throws -> ArgonExpressionNode
        {
        return(ArgonExpressionNode())
        }
    
    private func parseSymbolExpression() throws -> ArgonExpressionNode
        {
        return(ArgonExpressionNode())
        }
    
    private func parseTupleExpression() throws -> ArgonExpressionNode
        {
        if !token.isLeftPar
            {
            }
        return(ArgonExpressionNode())
        }
    
    private func parseIfStatement() throws -> ArgonMethodStatementNode
        {
        let frame = ArgonStackFrame.push(scope:scope)
        defer
            {
            ArgonStackFrame.pop()
            }
        var lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        try self.nextToken()
        frame.name = "IF-ELSE STATEMENT LINE @ \(token.location.lineNumber)"
        let condition = try self.parseExpression()
        guard condition.traits == ArgonStandardsNode.shared.booleanTraits else
            {
            throw(ParseError.booleanExpressionExpected)
            }
        let ifNode = ArgonIfStatementNode(containingScope:scope,condition:condition)
        ifNode.lineTrace = lineTrace
        ifNode.enclosingStackFrame = ArgonStackFrame.current()
        ArgonStackFrame.push(scope:ifNode)
        scope = ifNode
        defer
            {
            scope = ifNode.containingScope
            }
        try self.parseBraces
            {
            while !token.isRightBrace
                {
                ifNode.add(statement: try self.parseStatement())
                }
            }
        ArgonStackFrame.pop()
        lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        if token.isElse
            {
            let elseClause = ArgonElseClauseNode(containingScope:scope)
            elseClause.lineTrace = lineTrace
            elseClause.enclosingStackFrame = ArgonStackFrame.current()
            ArgonStackFrame.push(scope:elseClause)
            ifNode.elseClause = elseClause
            scope = elseClause
            defer
                {
                scope = elseClause.containingScope
                }
            try self.nextToken()
            try self.parseBraces
                {
                while !token.isRightBrace
                    {
                    elseClause.add(statement: try self.parseStatement())
                    }
                }
            ArgonStackFrame.pop()
            }
        return(ifNode)
        }
    
    private func parseParenthesis<T>(closure: () -> T) throws -> T
        {
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        let result = closure()
        if !token.isRightPar
            {
            throw(ParseError.rightParExpected)
            }
        try self.nextToken()
        return(result)
        }
    
    private func parseReturnStatement() throws -> ArgonMethodStatementNode
        {
        try self.nextToken()
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        var node:ArgonReturnStatementNode?
        try self.parseParenthesis
            {
            var returnType:ArgonType
            if scope.enclosingClosure() != nil
                {
                let closure = scope.enclosingClosure()!
                returnType = closure.resultType!
                }
            else
                {
                guard let method = scope.enclosingMethod() else
                    {
                    throw(ParseError.invalidSyntax)
                    }
                 returnType = method.returnType!
                }
            let result = try self.parseExpression()
            if !result.traits.inherits(from: returnType.traits)
                {
                throw(ParseError.typeMismatch)
                }
            node = ArgonReturnStatementNode(returnValue:result)
            node!.lineTrace = lineTrace
            }
        return(node!)
        }
    
    private func parseWhileStatement() throws -> ArgonMethodStatementNode
        {
        let lineTrace = ArgonLineTrace(line: self.token.location.lineNumber,start:self.token.location.lineStart,end:self.token.location.lineStop)
        try self.nextToken()
        let condition = try self.parseExpression()
        if condition.traits != ArgonStandardsNode.shared.booleanTraits
            {
            throw(ParseError.booleanExpressionExpected)
            }
        let container = ArgonWhileStatementNode(containingScope:scope,condition:condition)
        container.lineTrace = lineTrace
        let frame = ArgonStackFrame.push(scope:container)
        container.enclosingStackFrame = ArgonStackFrame.current()
        container.containingScope = scope
        scope = container
        frame.name = "WHILE STATEMENT LINE @ \(token.location.lineNumber)"
        defer
            {
            ArgonStackFrame.pop()
            }
        if !token.isLeftBrace
            {
            throw(ParseError.leftBraceExpected)
            }
        try self.nextToken()
        defer
            {
            scope = container.containingScope
            }
        while !token.isRightBrace
            {
            container.add(statement: try self.parseStatement())
            }
        try self.nextToken()
        return(container)
        }
    
    private func parseImport() throws
        {
        let moduleName = scope.enclosingModule().moduleName.string
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        let name = token.identifier!
        try self.nextToken()
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        var paths:[String] = []
        while !token.isRightPar
            {
            if !token.isString
                {
                throw(ParseError.pathExpected)
                }
            paths.append(token.string)
            try self.nextToken()
            if token.isComma
                {
                try self.nextToken()
                }
            }
        try self.nextToken()
        let node = ArgonImportNode(paths:paths)
        node.externalModuleName = ArgonName(name)
        if token.isStop
            {
            try self.nextToken()
            if !token.isIdentifier
                {
                throw(ParseError.identifierExpected)
                }
            node.itemName = ArgonName(name,token.identifier!)
            try self.nextToken()
            if !token.isAs
                {
                throw(ParseError.asExpected)
                }
            try self.nextToken()
            if !token.isIdentifier
                {
                throw(ParseError.identifierExpected)
                }
            node.internalName = ArgonName(moduleName,token.identifier!)
            try self.nextToken()
            }
        scope.add(node: node)
        }
    
    private func parsePath() throws -> String
        {
        var path:String = ""
        while token.isDiv || token.isIdentifier || token.isKeyword || token.isStop
            {
            if token.isDiv
                {
                path += "/"
                }
            else if token.isIdentifier
                {
                path += token.identifier!
                }
            else if token.isKeyword
                {
                path += token.keyword.rawValue
                }
            else if token.isStop
                {
                path += "."
                }
            try self.nextToken()
            }
        return(path)
        }
    
    private func parseExport() throws
        {
        var names:[ArgonName] = []
        let moduleName = scope.enclosingModule().moduleName
        repeat
            {
            try self.nextToken()
            if !token.isIdentifier
                {
                throw(ParseError.identifierExpected)
                }
            names.append(ArgonName(moduleName.string,token.identifier))
            try self.nextToken()
            }
        while token.isComma
        let exportNode = ArgonExportNode()
        exportNode.internalNames = names
        if names.count > 1
            {
            scope.add(node: exportNode)
            return
            }
        if !token.isAs
            {
            throw(ParseError.asExpected)
            }
        try self.nextToken()
        if !token.isIdentifier
            {
            throw(ParseError.identifierExpected)
            }
        exportNode.itemName = ArgonName(moduleName.string,token.identifier!)
        try self.nextToken()
        scope.add(node: exportNode)
        }
    
    private func parseBraces(_ closure: () throws -> Void) throws
        {
        if !token.isLeftBrace
            {
            throw(ParseError.leftBraceExpected)
            }
        try self.nextToken()
        try closure()
        if !token.isRightBrace
            {
            throw(ParseError.rightBraceExpected)
            }
        try self.nextToken()
        }
    
    private func parseParenthesis(_ closure: () throws -> Void) throws
        {
        if !token.isLeftPar
            {
            throw(ParseError.leftParExpected)
            }
        try self.nextToken()
        try closure()
        if !token.isRightPar
            {
            throw(ParseError.rightParExpected)
            }
        try self.nextToken()
        }
    }
