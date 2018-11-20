//
//  ModuleDisplayWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public class ModuleDisplayWrapper:DisplayItem
    {
    public private(set) var key = Argon.nextCounter
    
    public var name:String
        {
        return("Module")
        }
    
    public var icon:NSImage
        {
        return(NSImage(named:"Compile")!)
        }
        
    public var children:DisplayItemList
        {
        return(DisplayItemList())
        }
    
    public var nakedItem:Any?
        {
        return(nil)
        }
//    public var sectionEntryView:SectionEntryView
//        {
//        let pointer = UnsafeMutablePointer<NSArray?>.allocate(capacity: 1)
//        let objects = AutoreleasingUnsafeMutablePointer<NSArray?>(pointer)
//        let nib = NSNib(nibNamed: "SectionEntryView", bundle: nil)!
//        nib.instantiate(withOwner: nil, topLevelObjects: objects)
//        let sectionEntryView = ((objects.pointee!.filter{$0 is SectionEntryView})[0] as! SectionEntryView)
//        sectionEntryView.translatesAutoresizingMaskIntoConstraints = false
//        return(sectionEntryView)
//        }
    
    public static func configureColumns(in table:NSTableView,list:DisplayItemList)
        {
        if list[0].contentType != .traits
            {
            var count = table.tableColumns.count
            while count < 2
                {
                let newColumn = NSTableColumn()
                newColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(count)")
                count += 1
                }
            let columns = table.tableColumns
            columns[0].width = 24
            columns[1].width = table.bounds.width - 24
            }
        else
            {
            var count = table.tableColumns.count
            while count < 3
                {
                let newColumn = NSTableColumn()
                newColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(count)")
                count += 1
                }
            let columns = table.tableColumns
            columns[0].width = 24
            let width = list.maximumWidthOfNames(font: SystemPalette.shared.browserFont)
            columns[1].width = width
            columns[2].width = table.bounds.width - width - 24
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
        
    public var contentType:DisplayCellContentType
        {
        return(.default)
        }
    }

public class LibraryDisplayWrapper:ModuleDisplayWrapper
    {
    private let library:ArgonLibraryNode
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Library")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.library)
        }
    
    init(library:ArgonLibraryNode)
        {
        self.library = library
        }
    }

public class ExecutableDisplayWrapper:ModuleDisplayWrapper
    {
    private var executable:ArgonExecutable?
    private var _name:String = ""
    private var list = DisplayItemList()
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Executable")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.executable)
        }
    
    public override var children:DisplayItemList
        {
        if !list.isEmpty
            {
            return(list)
            }
        if executable == nil
            {
            executable = ArgonRepository.shared.executable(at: _name)
            guard executable != nil else
                {
                return(list)
                }
            }
//        for node in executable!.allNodes()
//            {
//            switch(node)
//                {
//                case is ArgonGenericMethodNode:
//                    list.append(GenericMethodDisplayWrapper(method: node as! ArgonGenericMethodNode))
//                case is ArgonTraitsNode:
//                    list.append(TraitsDisplayWrapper(traits: node as! ArgonTraitsNode))
//                case is ArgonLocalVariableNode:
//                    list.append(LocalDisplayWrapper(local: node as! ArgonLocalVariableNode))
//                case is ArgonNamedConstantNode:
//                    list.append(NamedConstantDisplayWrapper(constant: node as! ArgonNamedConstantNode))
//                case is ArgonImportNode:
//                    list.append(ImportExportDisplayWrapper(import: node as! ArgonImportNode))
//                case is ArgonExportNode:
//                    list.append(ImportExportDisplayWrapper(export: node as! ArgonExportNode))
//                case is ArgonEntryPointNode:
//                    list.append(EntryPointDisplayWrapper(point: node as! ArgonEntryPointNode))
//                default:
//                    break
//                }
//            }
        return(list)
        }
    
    public override var name:String
        {
        return(_name)
        }
    
    init(executable:ArgonExecutable)
        {
        self.executable = executable
        self._name  = executable.name
        }
    
    init(name:String)
        {
        self.executable = nil
        _name = name
        }
    }

public class RootDisplayWrapper:DisplayWrapper
    {
    private var list = DisplayItemList()
    
    public override var name:String
        {
        return("Argon")
        }
    
    public override var icon:NSImage
        {
        return(NSImage(named:"Compile")!)
        }
    
    public override var contentType:DisplayCellContentType
        {
        return(.default)
        }
    
    public override var children:DisplayItemList
        {
        get
            {
            return(list)
            }
        set
            {
            list = newValue
            }
        }
    }
