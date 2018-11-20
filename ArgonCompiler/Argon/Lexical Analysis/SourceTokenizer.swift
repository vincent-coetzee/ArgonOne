//
//  ArgonSourceTokenizer.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/23.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class SourceTokenizer:NSObject,NSTextViewDelegate,Model
    {
    private struct TokenStyle
        {
        var font:NSFont?
        var foreground:NSColor?
        var background:NSColor?
        
        public var attributes:[NSAttributedString.Key:Any]
            {
            var attributes:[NSAttributedString.Key:Any] = [:]
            
            if let aFont = font
                {
                attributes[.font] = aFont
                }
            if let aColor = foreground
                {
                attributes[.foregroundColor] = aColor
                }
            if let aColor = background
                {
                attributes[.backgroundColor] = aColor
                }
            return(attributes)
            }
        
        init(font:NSFont?,foreground:NSColor? = nil,background:NSColor? = nil)
            {
            self.font = font
            self.foreground = foreground
            self.background = background
            }
        }
    
    private let tokenStream = TokenStream()
    private var styles:[TokenType:TokenStyle] = [:]
    private var defaultFont:NSFont?
    public private(set) var tokens:[Token] = []
    private let editor:NSTextView
    public private(set) var dependents = DependentSet()
    
    public init(editor:NSTextView)
        {
        self.editor = editor
        super.init()
        self.initStyles()
        editor.delegate = self
        self.changed()
        tokenStream.parseComments = true
        }
    
    private func initStyles()
        {
        defaultFont = SystemPalette.shared.regularEditorFont
        var style = TokenStyle(font: defaultFont,foreground: NSColor(unscaledRed: 208,green: 104, blue: 148))
        styles[.keyword] = style
        style = TokenStyle(font: defaultFont,foreground: NSColor(unscaledRed: 130,green:193,blue: 183))
        styles[.string] = style
        style = TokenStyle(font: defaultFont,foreground: .pumpkin) // OK
        styles[.integer] = style
        styles[.float] = style
        style = TokenStyle(font: defaultFont,foreground: NSColor(unscaledRed: 163,green: 212,blue: 129))
        styles[.symbol] = style
        style = TokenStyle(font: SystemPalette.shared.boldItalicEditorFont,foreground: NSColor(unscaledRed: 139,green:133,blue:204))
        styles[.comment] = style
        style = TokenStyle(font: defaultFont,foreground: .cider) // OK
        styles[.traits] = style
        style = TokenStyle(font: SystemPalette.shared.boldEditorFont,foreground: NSColor(unscaledRed: 255,green: 161,blue:79))
        styles[.method] = style
        style = TokenStyle(font: defaultFont,foreground: NSColor(unscaledRed: 139,green: 133,blue: 204))
        styles[.local] = style
        }
    
    @objc public func textDidChange(_ notification:Notification)
        {
        self.changed()
        }
    
    private func changed()
        {
        do
            {
            tokenStream.setSource(editor.string)
            tokenStream.parseComments = true
            var token:Token = try tokenStream.nextToken()
            while token.type != .end
                {
                tokens.append(token)
                token = try tokenStream.nextToken()
                }
            }
        catch
            {
            }
        self.set(style: styles[.keyword]!,forAll: tokens.filter{$0.type == .keyword})
        self.set(style: styles[.symbol]!,forAll: tokens.filter{$0.type == .symbol})
        self.set(style: styles[.integer]!,forAll: tokens.filter{$0.type == .integer})
        self.set(style: styles[.comment]!,forAll: tokens.filter{$0.type == .comment})
        DispatchQueue.main.async
            {
            let parser = ArgonParser()
            do
                {
                let module = try parser.parse(self.editor.string)
                self.set(style: self.styles[.method]!,forAll: module.allMethods())
                self.set(style: self.styles[.local]!,forAll: module.allLocals())
                self.set(style: self.styles[.traits]!,forAll: module.allTraits())
                }
            catch
                {
                }
            }
        }
    
    private func set(style:TokenStyle,forAll:[ArgonParseNode])
        {
        let attributes = style.attributes
        for value in forAll
            {
            let range = NSRange(location: value.sourceLocation!.tokenStart,length: value.sourceLocation!.tokenStop - value.sourceLocation!.tokenStart)
            editor.textStorage?.setAttributes(attributes, range: range)
            }
        }
    
    private func set(style:TokenStyle,forAll:[Token])
        {
        let attributes = style.attributes
        for value in forAll
            {
            let range = NSRange(location: value.location.tokenStart,length: value.location.tokenStop - value.location.tokenStart)
            editor.textStorage?.setAttributes(attributes, range: range)
            }
        }
    }
