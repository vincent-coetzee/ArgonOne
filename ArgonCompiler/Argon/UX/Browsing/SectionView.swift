//
//  ArgonSectionView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class SectionView: NSView,NSTableViewDelegate,NSTableViewDataSource,Model,Dependent
    {
    private static let kViewIdentifier = "SectionEntryView"
    private static let kImageWidth:CGFloat = 24
    
    @IBOutlet weak var label:NSTextField!
    @IBOutlet weak var headingLabel:NSTextField!
    @IBOutlet weak var iconImage:NSImageView!
    @IBOutlet weak var table:NSTableView!
    
    private var fieldWidths:[String:CGFloat] = [:]
    public private(set) var dependents = DependentSet()
    public var selectedItem:DisplayItem?
    private var itemChildren = DisplayItemList()
    
    public var mainItem:DisplayItem?
        {
        didSet
            {
            self.changed(aspect:"selection",with: nil,from:self)
            self.itemChildren = DisplayItemList(parent: mainItem!)
            fieldWidths = DisplayWrapper.widthsForFields(list: itemChildren)
            self.refresh(from: mainItem)
            }
        }
    
    private func removeAllColumns()
        {
        let columns = table.tableColumns
        for column in columns
            {
            table.removeTableColumn(column)
            }
        }
    
    private func addColumns()
        {
        var column = NSTableColumn()
        column.identifier = NSUserInterfaceItemIdentifier(rawValue: "0")
        column.width = SectionView.kImageWidth
        table.addTableColumn(column)
        column = NSTableColumn()
        column.identifier = NSUserInterfaceItemIdentifier(rawValue: "1")
        let totalWidth = table.bounds.width
        table.addTableColumn(column)
        column.width = totalWidth - SectionView.kImageWidth
        if mainItem!.contentType == .traits
            {
            let maximum = itemChildren.maximumWidthOfNames(font: SystemPalette.shared.browserFont)
            column.width = maximum
            column = NSTableColumn()
            column.identifier = NSUserInterfaceItemIdentifier(rawValue: "2")
            table.addTableColumn(column)
            let remainder = totalWidth - SectionView.kImageWidth - maximum
            column.width = remainder
            }
        }
    
    private func refresh(from anItem:DisplayItem?)
        {
        guard anItem != nil else
            {
            self.label.stringValue  = ""
            self.headingLabel.stringValue = ""
            self.iconImage.image = nil
            self.itemChildren = DisplayItemList()
            table.reloadData()
            return
            }
        self.label.stringValue = anItem!.name
        self.iconImage.image = anItem!.icon
        self.headingLabel.stringValue = "Contents of:"
        table.reloadData()
        }
   

    public override func awakeFromNib()
        {
        self.table.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle
        self.table.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue:"FirstColumn"))?.resizingMask = .autoresizingMask
        self.table.intercellSpacing = NSSize(width:0,height:0)
        self.label.stringValue  = ""
        self.headingLabel.stringValue = ""
        self.iconImage.image = nil
        table.delegate = self
        table.dataSource = self
        table.register(NSNib(nibNamed: "SectionEntryView", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: SectionView.kViewIdentifier))
        self.label.stringValue = ""
        }
    
    public func update(aspect:String,with:Any?,from:Model)
        {
        if aspect == "selection"
            {
            if with == nil
                {
                itemChildren = DisplayItemList()
                table.reloadData()
                }
            else
                {
                let inItem = with as! DisplayItem
                self.mainItem = inItem
                }
            }
        }
    
    public func tableViewSelectionDidChange(_ notification: Notification)
        {
        let row = table.selectedRow
        guard row >= 0 else
            {
            return
            }
        selectedItem = itemChildren[row]
        self.changed(aspect:"selection",with: selectedItem,from:self)

        }

    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        return(itemChildren.count)
        }

//    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView?
//        {
//        return(SectionTableRowView(frame: .zero))
//        }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
        guard let column = tableColumn else
            {
            return(nil)
            }
        let displayItem = itemChildren[row]
        let view = displayItem.render(column: column)
        return(view)
        }
//
//    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
//        {
//        let displayItem = itemChildren[row]
//        let sectionEntryView = displayItem.sectionEntryView(left:leftColumn,right:rightColumn)
//        sectionEntryView.displayItem = displayItem
//        return(sectionEntryView)
//        }
    }
