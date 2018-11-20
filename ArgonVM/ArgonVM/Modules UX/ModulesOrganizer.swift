//
//  ModulesOrganizer.swift
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/17.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Cocoa

public struct ModulesOrganizer
    {
    fileprivate struct ModuleEntry
        {
        fileprivate var packageSize:Int = 0
        fileprivate var module:ArgonModule
        fileprivate var methodCount:Int = 0
        fileprivate var traitsCount:Int = 0
        
        init(module:ArgonModule)
            {
            self.module = module
            }
        }
    
    private var entries:[Int:ModuleEntry] = [:]
    
    public mutating func set(packageSize:Int,traitsCount:Int,methodCount:Int,for module:ArgonModule)
        {
        var entry = ModuleEntry(module:module)
        entry.packageSize = packageSize
        entry.methodCount = methodCount
        entry.traitsCount = traitsCount
        entries[module.id] = entry
        }
    
    public func update(view:ArgonElementCellView,for module:ArgonModule)
        {
        guard let entry = entries[module.id] else
            {
            return
            }
        let byteCountFormatter = ByteCountFormatter()
        view.sizeField.stringValue = byteCountFormatter.string(fromByteCount: Int64(entry.packageSize))
        view.traitsCountField.stringValue = "\(entry.traitsCount) traits in module"
        view.methodsCountField.stringValue = "\(entry.methodCount) methods in module"
        view.labelText = module.fullName
        view.iconImage = module.isExecutable ? NSImage(named:"ArgonExecutableIcon")! : NSImage(named:"ArgonLibraryIcon")!
        }
    }
