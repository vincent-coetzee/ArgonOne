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
    }
