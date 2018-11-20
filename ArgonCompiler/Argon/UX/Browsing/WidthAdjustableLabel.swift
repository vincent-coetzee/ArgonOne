//
//  WidthAdjustableLabel.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/29.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class WidthAdjustableLabel: NSView
    {
    private var textWidth:CGFloat = 0
    private var textString = NSAttributedString(string:"",attributes:nil)
    
    public var width:CGFloat? = nil
        {
        didSet
            {
            self.update(from: width)
            }
        }
    public var text:String = ""
        {
        didSet
            {
            self.update(from: text)
            }
        }
    
    private func update(from: String)
        {
        let attributes:[NSAttributedString.Key:Any] = [.font:SystemPalette.shared.browserFont,.foregroundColor:SystemPalette.shared.browserTitlesColor]
        textString = NSAttributedString(string: from,attributes:attributes)
        textWidth = textString.size().width
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.needsDisplay = true
        }
    
    public override var intrinsicContentSize: NSSize
        {
        return(NSSize(width: textWidth + 8,height: NSView.noIntrinsicMetric))
        }
    
    private func update(from someFloat:CGFloat?)
        {
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.needsDisplay = true
        }
    
    override func draw(_ dirtyRect: NSRect)
        {
        var rect = self.bounds
        rect.origin.x = 4
        rect.size = NSSize(width: textWidth,height: rect.height)
        textString.draw(in: rect)
        }
    
    }
