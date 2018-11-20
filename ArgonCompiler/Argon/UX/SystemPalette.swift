//
//  SystemPalette.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public struct SystemPalette
    {
    public static let shared = SystemPalette()
    
    public var regularEditorFont = NSFont(name:"Menlo-Regular",size:13)
    public var boldEditorFont = NSFont(name:"Menlo-Bold",size:13)
    public var boldItalicEditorFont = NSFont(name:"Menlo-BoldItalic",size:13)
    public var cartoucheFont:NSFont = NSFont(name:"Menlo",size: 11)!
    public var browserFont:NSFont = NSFont(name:"Menlo-Bold",size: 13)!
    public var browserTitlesColor = NSColor.white
    public var cartoucheBackgroundColor = NSColor.argonPink
    public var cartoucheTextColor = NSColor.argonPink
    public var cartoucheLineColor = NSColor.argonPink
    public var cartoucheTextAttributes:[NSAttributedString.Key:Any]
    public var browserTextAttributes:[NSAttributedString.Key:Any]
    
    public var cartoucheFontHeight:CGFloat
        {
        return(self.cartoucheFont.capHeight + abs(cartoucheFont.descender))
        }
    
    public var browserFontHeight:CGFloat
        {
        return(self.browserFont.capHeight + abs(browserFont.descender))
        }
    
    public init()
        {
        self.cartoucheTextAttributes = [.font:cartoucheFont,.foregroundColor:self.cartoucheTextColor]
        self.browserTextAttributes = [.font:browserFont,.foregroundColor:self.browserTitlesColor]
        }
    
    public func width(of string:String,in font:NSFont) -> CGFloat
        {
        let attributes:[NSAttributedString.Key:Any] = [.font:font]
        return(NSAttributedString(string: string,attributes:attributes).size().width)
        }
    }
