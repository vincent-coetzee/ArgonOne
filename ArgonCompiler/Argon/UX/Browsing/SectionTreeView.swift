//
//  SectionTreeView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/28.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class SectionTreeView: NSView,NSOutlineViewDataSource,NSOutlineViewDelegate,Model,Dependent
    {
    static let kViewIdentifier = "SectionEntry"
    
    @IBOutlet weak var headingLabel:NSTextField!
    @IBOutlet weak var label:NSTextField!
    @IBOutlet weak var iconImage:NSImageView!
    @IBOutlet weak var outliner:NSOutlineView!
    
    public private(set) var dependents = DependentSet()
    private var maximumLabelWidth:CGFloat = 0
    private var maximumExtraWidth:CGFloat = 0
    
    public var text:String = ""
        {
        didSet
            {
            self.label.stringValue = text
            }
        }
    
    public var icon:NSImage = NSImage()
        {
        didSet
            {
            self.iconImage.image = icon
            }
        }
    
    public var items:DisplayItemList = DisplayItemList()
        {
        didSet
            {
            self.refresh()
            }
        }
    
    public func update(aspect:String,with:Any?,from:Model)
        {
        if aspect == "selection"
            {
            if with != nil
                {
                self.items = DisplayItemList(parent: with as! DisplayItem)
                }
            else
                {
                self.items = DisplayItemList()
                }
            outliner.reloadData()
            self.changed(aspect:"selection",with:nil,from:self)
            }
        }
    
    private func refresh()
        {
        if items.count > 0 && items[0].contentType == .slot
            {
            var width:CGFloat = 0
            let attributes = SystemPalette.shared.browserTextAttributes
            for kid in items
                {
                let slot = kid.nakedItem as! ArgonSlotNode
                width = max(width,NSAttributedString(string:slot.traits.name.string,attributes:attributes).size().width)
                }
            maximumExtraWidth = width
            }
        outliner.tableColumns[0].width = outliner.bounds.width
        outliner.reloadData()
        }
    
    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
        let selectedRow = outliner.selectedRow
        if selectedRow >= 0
            {
            let anItem = outliner.item(atRow: selectedRow)
            self.changed(aspect:"selection",with:anItem,from:self)
            }
        }
    
    public func outlineViewItemWillExpand(_ notification: Notification)
        {
        let userInfo = notification.userInfo!
        let item = userInfo["NSObject"]! as! DisplayItem
        if item.contentType == .traits
            {
            let attributes = SystemPalette.shared.browserTextAttributes
            let kids = DisplayItemList(parent:item)
            var width:CGFloat = 0
            for kid in kids
                {
                let slot = kid.nakedItem as! ArgonSlotNode
                width = max(width,NSAttributedString(string:slot.traits.name.string,attributes:attributes).size().width)
                }
            maximumExtraWidth = width
            }
        else
            {
            maximumExtraWidth = 0
            }
        }
    
    public func outlineViewItemDidExpand(_ notification: Notification)
        {
//        let rowCount = outliner.numberOfRows
//        var list = DisplayItemList()
//        var views:[ImageLabelExtraView] = []
//        for row in 0..<rowCount
//            {
//            let item = outliner.item(atRow: row) as! DisplayItem
//            views.append(outliner.view(atColumn: 0, row: row, makeIfNecessary: false) as! ImageLabelExtraView)
//            list.append(item)
//            }
//        let widths = DisplayWrapper.widthsForFields(list: list)
//        maximumLabelWidth = widths["maximumNameWidth"]!
//        maximumExtraWidth = widths["maximumExtraWidth"]!
//        for view in views
//            {
//            view.labelWidth
//            }
        }
    
    public override func awakeFromNib()
        {
        outliner.delegate = self
        outliner.dataSource = self
        }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(items.count)
            }
        else if let displayItem = item as? DisplayItem
            {
            return(displayItem.childCount)
            }
        return(0)
        }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let displayItem = item as! DisplayItem
        return(displayItem.childCount > 0)
        }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item == nil
            {
            return(items[index])
            }
        else if let displayItem = item as? DisplayItem
            {
            return(displayItem.children[index])
            }
        fatalError("Should not happen")
        }
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        guard let displayItem = item as? DisplayItem else
            {
            return(nil)
            }
        let view = ImageLabelExtraView(frame:.zero)
        view.set(displayItem: displayItem,extraViewWidth: maximumExtraWidth)
        return(view)
        }
    }
