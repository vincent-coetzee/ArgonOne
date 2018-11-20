//
//  NSColor+Extensions.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/23.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

extension NSColor
    {
    public static let ruby = NSColor(0xE0115F)
    public static let denim = NSColor(0x131E3A)
    public static let forest = NSColor(0x0B6623)
    public static let pumpkin = NSColor(0xFF7417)
    public static let dijon = NSColor(0xC49102)
    public static let independence = NSColor(0x4D516D)
    public static let jade = NSColor(0x00A86B)
    public static let artichoke = NSColor(0x8F9779)
    public static let tortilla = NSColor(0x997950)
    public static let olive = NSColor(0x708238)
    public static let lollipop = NSColor(0x81007F)
    public static let cider = NSColor(0xB3672B)
    public static let cerise = NSColor(0xDE3163)
    public static let flaxen = NSColor(0xD5B85A)
    public static let punch = NSColor(0xEC5578)
    public static let sacramento = NSColor(0x043927)
    public static let prussian = NSColor(0x003151)
    public static let argonPink = NSColor(0xEE2A7B)
    
    convenience init(_ value:Int)
        {
        let red = CGFloat((value & (255 << 16)) >> 16) / 255.0
        let green = CGFloat((value & (255 << 8)) >> 8) / 255.0
        let blue = CGFloat((value & 255)) / 255.0
        self.init(red: red,green: green,blue: blue,alpha: 1.0)
        }
    
    convenience init(unscaledRed red:Int,green:Int,blue:Int)
        {
        let newRed = CGFloat(red) / 255.0
        let newGreen = CGFloat(green) / 255.0
        let newBlue = CGFloat(blue) / 255.0
        self.init(red: newRed,green:newGreen,blue:newBlue,alpha: 1)
        }
    }
