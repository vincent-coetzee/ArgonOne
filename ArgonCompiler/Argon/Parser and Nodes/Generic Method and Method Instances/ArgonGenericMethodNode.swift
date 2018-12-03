//
//  ArgonGenericMethod.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/06.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class MethodParameterType
    {
    public var traits:ArgonTraitsNode?
    public var traitsPointer:Pointer?

    init(traits:ArgonTraitsNode)
        {
        self.traits = traits
        }
    }



public class ArgonGenericMethodNode:ArgonMethodNode,ArgonExportableItem,ArgonRelocatable
    {
    public private(set) var instances:[ArgonMethodNode] = []
    public var parameterCount:Int = 0
    public var parameterTraits:[ArgonTraitsNode] = []
    public private(set) var selectionTreeRoot:GenericMethodParentNode = GenericMethodParentNode(kindHolder:KindHolder())
    public private(set) var allowsAnyArity = false
    public var fullName:ArgonName = ArgonName("")
    public private(set) var returnTraits:ArgonTraitsNode = ArgonStandardsNode.shared.voidTraits
    
    public var hasInlineDirective:Bool
        {
        return(directives.contains(ArgonMethodDirective.inline))
        }
    
    public var hasStaticDirective:Bool
        {
        return(directives.contains(ArgonMethodDirective.static))
        }
    
    public var hasSystemDirective:Bool
        {
        return(directives.contains(ArgonMethodDirective.system))
        }
    
    public var hasDynamicDirective:Bool
        {
        return(directives.contains(ArgonMethodDirective.dynamic))
        }
    
    public func asArgonGenericMethod() -> ArgonGenericMethod
        {
        let new = ArgonGenericMethod(fullName: self.fullName.string)
        new.allowsAnyArity = self.allowsAnyArity
        new.fullName = self.fullName.string
        new.returnTraits = self.returnTraits.asArgonTraits()
        new.instances = self.instances.map {$0.asArgonMethod()}
        new.parameterCount = self.parameterCount
        new.id = self.id
        new.directives = directives
        return(new)
        }
    
    public override func generateCode(with generator:ThreeAddressCodeGenerator) throws
        {
        for method in instances
            {
            try method.generateCode(with: generator)
            }
        }
    
    public override func dump()
        {
        for method in instances
            {
            method.dump()
            }
        }
    public var isPrimitiveBasedMethod:Bool
        {
        return(false)
        }
    
    public override var arity:Int
        {
        return(parameterCount)
        }
    
    public override var isGenericMethod:Bool
        {
        return(true)
        }
    
    public override var moduleName:ArgonName
        {
        get
            {
            return(super.moduleName)
            }
        set
            {
            super.moduleName = newValue
            scopedName = newValue + name.string
            }
        }
    
    public func add(instance:ArgonMethodNode)
        {
        if instances.count == 0
            {
            self.returnTraits = instance.returnType.traits
            self.parameters = instance.parameters
            parameterCount = instance.parameters.count
            }
        instance.directives = directives
        instance.moduleName = self.moduleName
        instances.append(instance)
        let traitsList = instances.map {$0.parameters.map {$0.traits}}
        parameterTraits = traitsList.map {$0.sorted(by: {$1.inherits(from: $0)})[0]}
        }
    
    public func canDispatch(forTraits:[ArgonTraitsNode]) -> Bool
        {
        for instance in instances
            {
            if instance.couldDispatch(forTraits:forTraits)
                {
                return(true)
                }
            }
        return(false)
        }
    
    public func isValid(returnType:ArgonTraitsNode) -> Bool
        {
        if returnType.isInInheritanceGraph(of: self.returnTraits)
            {
            if returnTraits.inherits(from: returnType)
                {
                self.returnTraits = returnType
                }
            return(true)
            }
        return(false)
        }

    public override func threeAddress(pass:ThreeAddressPass) throws
        {
        for method in instances
            {
            try method.threeAddress(pass: pass)
            }
        }
    }
