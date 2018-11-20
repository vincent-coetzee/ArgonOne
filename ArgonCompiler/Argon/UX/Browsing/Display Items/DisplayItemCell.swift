//
//  DisplayItemCell.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa



public class DisplayItemCell:NSBrowserCell
    {
    public var contentType:DisplayCellContentType = .default
    public var drawType = false
    public var typeName = ""
    public var typeNameOffset = CGFloat(0)
    public var typeNameMaximumLength = CGFloat(0)
    
    public override init(imageCell:NSImage?)
        {
        super.init(imageCell:imageCell)
        }
    
    public override init(textCell:String)
        {
        super.init(textCell:textCell)
        }
    
    required init(coder:NSCoder)
        {
        super.init(coder:coder)
        }
    
    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView)
        {
        switch(contentType)
            {
            case .slot:
                self.drawSlotInterior(withFrame: cellFrame,in:controlView)
            default:
                self.drawDefaultInterior(withFrame:cellFrame,in:controlView)
            }
        }
    
    private func drawDefaultInterior(withFrame cellFrame: NSRect, in controlView: NSView)
        {
        var offset = self.drawIcon(at: 4,in:cellFrame)
        offset = self.drawTitle(at: offset,in: cellFrame)
        }
    
    private func drawSlotInterior(withFrame cellFrame: NSRect, in controlView: NSView)
        {
        var offset = self.drawIcon(at: 4,in:cellFrame)
        offset = self.drawTitle(at: offset,in: cellFrame)
        offset = self.drawTypeName(at: typeNameOffset,length: typeNameMaximumLength,in:cellFrame)
        }
    
    private func drawIcon(at offset:CGFloat,in cellFrame:NSRect) -> CGFloat
        {
        let icon = self.image
        let iconSize = icon!.size
        let imageDelta = (cellFrame.height - iconSize.height) / 2.0
        icon!.draw(in: NSRect(origin: NSPoint(x:imageDelta + cellFrame.minX,y:imageDelta + cellFrame.minY),size: iconSize))
        return(iconSize.width + offset + imageDelta)
        }
    
    private func drawTitle(at offset:CGFloat,in cellFrame:NSRect) -> CGFloat
        {
        let text = self.title
        let string = NSAttributedString(string: text,attributes: [.font:SystemPalette.shared.browserFont as Any,.foregroundColor:NSColor.white])
        var rect = string.boundingRect(with: .zero,options: [.usesDeviceMetrics])
        rect.origin = cellFrame.origin
        rect.origin.y += (cellFrame.height - rect.height) / 2.0
        let verticalDelta = (cellFrame.height - SystemPalette.shared.browserFontHeight) / 2.0
        string.draw(at: NSPoint(x: offset + cellFrame.minX,y: cellFrame.origin.y))
        return(offset + rect.width + verticalDelta)
        }
    
    private func drawTypeName(at offset:CGFloat,length:CGFloat,in cellFrame:NSRect) -> CGFloat
        {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let string = NSAttributedString(string: typeName,attributes: [.font:SystemPalette.shared.cartoucheFont as Any,.foregroundColor:NSColor.white,.paragraphStyle:style])
        let rect = string.boundingRect(with: .zero,options: [.usesDeviceMetrics])
        let verticalDelta = (cellFrame.height - SystemPalette.shared.cartoucheFontHeight) / 2.0
        let delta:CGFloat = 3.0
        var cartoucheRect = NSRect(x: cellFrame.maxX - length - 8,y:delta + cellFrame.minY,width:length + 8,height: cellFrame.height - 2.0*delta)
        let path = NSBezierPath(roundedRect: cartoucheRect, xRadius: 3, yRadius: 3)
        SystemPalette.shared.cartoucheBackgroundColor.set()
        path.lineWidth = 2
        path.stroke()
        cartoucheRect.origin.y -= delta
        string.draw(in: cartoucheRect)
//        string.draw(at: NSPoint(x: cellFrame.maxX - length - 6,y: cellFrame.minY))
        return(offset + rect.width + verticalDelta)
        }
    }
