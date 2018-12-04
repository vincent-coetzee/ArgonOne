//
//  ArgonModule.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum ArgonModuleItemKind:Int
    {
    case genericMethod
    case constant
    case traits
    case closure
    case string
    case symbol
    case global
    case none
    case integer
    case float
    case boolean
    case tree
    case handler
    case method
    
    public init(archiver: CArchiver) throws
        {
        var type:Int = 0
        fread(&type,MemoryLayout<Int>.size,1,archiver.file)
        self.init(rawValue: type)!
        }
    
    public func write(archiver: CArchiver) throws
        {
        var type = self.rawValue
        fwrite(&type,MemoryLayout<Int>.size,1,archiver.file)
        }
    }

public protocol ArgonModuleItem
    {
    var externalName:ArgonName { get }
    var pointer:Pointer { get }
    var kind:ArgonModuleItemKind { get }
    }

public class ArgonModule:ArgonModulePart
    {
    public private(set) var imports:[String:ArgonImport] = [:]
    public var relocations = ArgonRelocationTable()
    public var traits = [String:ArgonTraits]()
    public var source:String = ""
    
    public override init(fullName:String)
        {
        super.init(fullName:fullName)
        }
    
    public func prepareForPackaging(_ relocationTable:ArgonRelocationTable)
        {
        self.relocations = relocationTable
        relocationTable.buildRelocationEntries()
        self.traits = ArgonRelocationTable.shared.traitsByFullName
        }
    
    public override func encode(with aCoder: NSCoder)
        {
        super.encode(with: aCoder)
        aCoder.encode(imports,forKey:"imports")
        aCoder.encode(relocations,forKey:"relocations")
        aCoder.encode(traits,forKey:"traits")
        aCoder.encode(source,forKey:"source")
        }
    
    public required init?(coder aDecoder: NSCoder)
        {
        imports = aDecoder.decodeObject(forKey: "imports") as! [String:ArgonImport]
        relocations = aDecoder.decodeObject(forKey: "relocations") as! ArgonRelocationTable
        traits = aDecoder.decodeObject(forKey: "traits") as! [String:ArgonTraits]
        source = aDecoder.decodeObject(forKey: "source") as! String
        super.init(coder:aDecoder)
        }
    
    required public init(archiver: CArchiver) throws
        {
        source = try String(archiver: archiver)
        relocations = try ArgonRelocationTable(archiver: archiver)
        try super.init(archiver: archiver)
        }
    
    public override func write(archiver: CArchiver) throws
        {
        try archiver.write(object: self)
        try super.write(archiver: archiver)
        try source.write(archiver: archiver)
        try relocations.write(archiver: archiver)
        }
    
    }
