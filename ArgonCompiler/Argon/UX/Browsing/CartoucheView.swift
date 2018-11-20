//
//  CartoucheView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class CartoucheView:NSView
    {
    private var attributes:[NSAttributedString.Key:Any] = [:]
    
//    public override func awakeFromNib()
//        {
//        super.awakeFromNib()
//        self.wantsLayer = true
//        self.layer?.backgroundColor = NSColor.orange.cgColor
//        }
//    
    public var text:String = ""
        {
        didSet
            {
            self.needsDisplay = true
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            attributes = [.font:SystemPalette.shared.cartoucheFont,.foregroundColor: SystemPalette.shared.cartoucheTextColor,.paragraphStyle:style]
            }
        }
    
    public override func draw(_ rect:NSRect)
        {
        let path = NSBezierPath(roundedRect: self.bounds.insetBy(dx: 2, dy: 2), xRadius: 3, yRadius: 3)
        SystemPalette.shared.cartoucheLineColor.setStroke()
        path.lineWidth = 1
        path.stroke()
        let textBounds = self.bounds.insetBy(dx: 2, dy: 2)
        NSAttributedString(string:self.text,attributes: attributes).draw(in: textBounds)
        }
    }
