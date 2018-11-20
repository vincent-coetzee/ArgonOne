//
//  ListView.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public protocol ListViewDelegate:class
    {
    func didSelect(row:Int)
    }

class ListView: NSTableView
    {
    public weak var listViewDelegate:ListViewDelegate?
    
    public var list:[String] = []
        {
        didSet
            {
            self.reloadData()
            }
        }
    
    public var attributedList:[NSAttributedString] = []
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
        self.register(NSNib(nibNamed: "ListViewCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ListViewCell"))
        self.dataSource = self
        self.delegate = self
        }
    }

extension ListView:NSTableViewDelegate
    {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ListViewCell"), owner: nil) as! ListViewCell
        if list.isEmpty
            {
            cell.attributedStringValue = attributedList[row]
            }
        else
            {
            cell.stringValue = list[row]
            }
        return(cell)
        }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool
        {
        let string = list[row]
        listViewDelegate?.didSelect(row: row)
        return(true)
        }
    }
    
extension ListView:NSTableViewDataSource
    {
    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        if list.isEmpty
            {
            if attributedList.isEmpty
                {
                return(0)
                }
            else
                {
                return(attributedList.count)
                }
            }
        return(list.count)
        }
    }
