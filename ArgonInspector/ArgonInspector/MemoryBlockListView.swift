//
//  ListView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

class MemoryBlockListView: NSTableView
    {
    public var list:[ArgonInstanceElement] = []
        {
        didSet
            {
            self.reloadData()
            }
        }
    
    public var selectedIndex:Int = 0
        {
        didSet
            {
            let indexSet:IndexSet = [selectedIndex]
            self.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
        }
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.register(NSNib(nibNamed: "SlotCellView", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SlotCellView"))
        self.register(NSNib(nibNamed: "InstanceHeaderCellView", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InstanceHeaderCellView"))
        self.dataSource = self
        self.delegate = self
        }
    }

extension MemoryBlockListView:NSTableViewDelegate
    {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
        {
        return(list[row].cellHeight())
        }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
        let cellType = list[row].cellIdentifier
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellType), owner: nil)
        list[row].initCell(view: cell)
        return(cell)
        }
    }
    
extension MemoryBlockListView:NSTableViewDataSource
    {
    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        return(list.count)
        }
    }
