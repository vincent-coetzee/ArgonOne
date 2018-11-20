//
//  DisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class DisplayWrapper:DisplayItem
    {
    public private(set) var key = Argon.nextCounter

     public var name:String
        {
        return("Name")
        }

    public var icon:NSImage
        {
        return(NSImage(named:"Empty")!)
        }

    public var children:DisplayItemList
        {
        return(DisplayItemList())
        }

    public var nakedItem:Any?
        {
        return(nil)
        }
    
    public static func widthsForFields(list:DisplayItemList) -> [String:CGFloat]
        {
        var nameWidth:CGFloat = 0
        var traitsNameWidth:CGFloat = 0
        let attributes:[NSAttributedString.Key:Any] = [.font:SystemPalette.shared.browserFont]
        for item in list
            {
            nameWidth = max(nameWidth,NSAttributedString(string: item.name,attributes:attributes).size().width)
            if item.contentType == .slot
                {
                let slot = item.nakedItem as! ArgonSlotNode
                traitsNameWidth = max(traitsNameWidth,NSAttributedString(string: slot.traits.name.string,attributes:attributes).size().width)
                }
            }
        return(["maximumNameWidth":nameWidth,"maximumExtraWidth":traitsNameWidth])
        }
    
    public static func configureColumns(in table:NSTableView,list:DisplayItemList)
        {
        if list.count < 1
            {
            return
            }
        if list[0].contentType != .slot
            {
            var count = table.tableColumns.count
            while count < 2
                {
                let newColumn = NSTableColumn()
                newColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(count)")
                table.addTableColumn(newColumn)
                count += 1
                }
            let columns = table.tableColumns
            let width = columns[0].width
            columns[1].width = table.bounds.width - width
            }
        else
            {
            let attributes:[NSAttributedString.Key:Any] = [.font:SystemPalette.shared.browserFont]
            var maxWidth:CGFloat = 0
            for item in list
                {
                let actualItem = item.nakedItem as! ArgonSlotNode
                maxWidth = Swift.max(maxWidth,NSAttributedString(string: actualItem.traits.name.string,attributes: attributes).size().width)
                }
            maxWidth += 12
            var count = table.tableColumns.count
            while count < 3
                {
                let newColumn = NSTableColumn()
                newColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(count)")
                table.addTableColumn(newColumn)
                count += 1
                }
            let columns = table.tableColumns
            let firstWidth = columns[0].width
            let width = list.maximumWidthOfNames(font: SystemPalette.shared.browserFont)
            columns[1].width = width
            let finalWidth = min(maxWidth,table.bounds.width - width - firstWidth)
            columns[2].width = finalWidth
            }
        }
    
    public func render(column:NSTableColumn) -> NSView?
        {
        if column.identifier.rawValue == "0"
            {
            let view = NSImageView(frame: .zero)
            view.image = self.iconImage
            return(view)
            }
        else if column.identifier.rawValue == "1"
            {
            let view = NSTextField(labelWithString: self.name)
            return(view)
            }
        return(nil)
        }
    
//    public func sectionEntryView(left:Column,right:Column) -> SectionEntryView
//        {
//        let pointer = UnsafeMutablePointer<NSArray?>.allocate(capacity: 1)
//        let objects = AutoreleasingUnsafeMutablePointer<NSArray?>(pointer)
//        let nib = NSNib(nibNamed: "SectionEntryView", bundle: nil)!
//        nib.instantiate(withOwner: nil, topLevelObjects: objects)
//        let sectionEntryView = ((objects.pointee!.filter{$0 is SectionEntryView})[0] as! SectionEntryView)
//        sectionEntryView.translatesAutoresizingMaskIntoConstraints = false
//        return(sectionEntryView)
//        }
        
    public var contentType:DisplayCellContentType
        {
        return(.default)
        }

    public var traitsName:String
        {
        return("Traits")
        }
    }
