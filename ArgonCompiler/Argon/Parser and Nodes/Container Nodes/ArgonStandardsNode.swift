//
//  ArgonStandardsNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonStandardsNode:ArgonTopLevelNode
    {
    public static var shared:ArgonStandardsNode!
    
    public static func initialize()
        {
        self.shared = ArgonStandardsNode(name:"Argon")
        self.shared.initPrimitives()
        }
    
    public private(set) var booleanTraits:ArgonTraitsNode
    public private(set) var integerTraits:ArgonTraitsNode
    public private(set) var errorTraits:ArgonTraitsNode
    public private(set) var voidTraits:ArgonTraitsNode
    public private(set) var stringTraits:ArgonTraitsNode
    public private(set) var floatTraits:ArgonTraitsNode
    public private(set) var closureTraits:ArgonTraitsNode
    public private(set) var symbolTraits:ArgonTraitsNode
    public private(set) var vectorTraits:ArgonTraitsNode
    public private(set) var anyTraits:ArgonTraitsNode
    public private(set) var behaviorTraits:ArgonTraitsNode
    public private(set) var traitsTraits:ArgonTraitsNode
    public private(set) var doubleTraits:ArgonTraitsNode
    public private(set) var polymorphicArgumentTraits:ArgonTraitsNode
    public private(set) var conditionTraits:ArgonTraitsNode
    
    public override init(name:ArgonName)
        {
        voidTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Void"))
        voidTraits.asArgonTraits()
        polymorphicArgumentTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::PolymorphicArgument"))
        polymorphicArgumentTraits.parents = [voidTraits]
        polymorphicArgumentTraits.asArgonTraits()
        behaviorTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Behaviour"))
        behaviorTraits.asArgonTraits()
        conditionTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Condition"))
        conditionTraits.parents = [behaviorTraits]
        conditionTraits.asArgonTraits()
        traitsTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::TraitsTraits"))
        anyTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Any"))
        anyTraits.parents = [behaviorTraits]
        anyTraits.asArgonTraits()
        errorTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Error"))
        errorTraits.parents = [behaviorTraits]
        errorTraits.asArgonTraits()
        closureTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Closure"))
        closureTraits.parents = [behaviorTraits]
        closureTraits.asArgonTraits()
        let method = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Method"))
        method.parents = [behaviorTraits]
        method.asArgonTraits()
        let genericMethod = ArgonProxyTraitsNode(fullName: ArgonName("Argon::GenericMethod"))
        genericMethod.parents = [method]
        genericMethod.asArgonTraits()
        let traits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Traits"))
        traits.parents = [behaviorTraits]
        traits.asArgonTraits()
        traitsTraits.parents = [traits]
        traitsTraits.asArgonTraits()
        let collection = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Collection"))
        collection.parents = [traits]
        collection.asArgonTraits()
        let vector = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Vector"))
        vector.parents = [collection]
        vector.asArgonTraits()
        vectorTraits = vector
        stringTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::String"))
        stringTraits.parents = [vector]
        stringTraits.asArgonTraits()
        let number = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Number"))
        number.parents = [traits]
        number.asArgonTraits()
        integerTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Integer"))
        integerTraits.parents = [number]
        integerTraits.asArgonTraits()
        symbolTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Symbol"))
        symbolTraits.parents = [stringTraits]
        symbolTraits.asArgonTraits()
        booleanTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Boolean"))
        booleanTraits.parents = [symbolTraits]
        booleanTraits.asArgonTraits()
        floatTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Float"))
        doubleTraits = ArgonProxyTraitsNode(fullName: ArgonName("Argon::Double"))
        doubleTraits.parents = [number]
        doubleTraits.asArgonTraits()
        floatTraits.parents = [number]
        floatTraits.asArgonTraits()
        super.init(name:name)
        self.add(node: polymorphicArgumentTraits)
        self.add(node: voidTraits)
        self.add(node: errorTraits)
        self.add(node: behaviorTraits)
        self.add(node: method)
        self.add(node: closureTraits)
        self.add(node: floatTraits)
        self.add(node: booleanTraits)
        self.add(node: symbolTraits)
        self.add(node: integerTraits)
        self.add(node: number)
        self.add(node: vector)
        self.add(node: stringTraits)
        self.add(node: collection)
        self.add(node: traits)
        self.add(node: traitsTraits)
        self.add(node: genericMethod)
        }
    
    public func symbol(at name:ArgonName) -> ArgonParseNode?
        {
        if let node = keyedTypes[name]
            {
            return(node)
            }
        else
            {
            for local in locals
                {
                if local.name == name
                    {
                    return(local)
                    }
                }
            }
        return(nil)
        }
    
    private func initPrimitiveTraits()
        {

        }
    
    private func initPrimitives()
        {
        let make = ArgonGenericMethodNode(name:"make")
        make.isPrimitive = true
        self.add(node: make)
        let random = ArgonGenericMethodNode(name:"random")
        random.isPrimitive = true
        random.parameterCount = 3
        random.returnType = self.integerTraits
        self.add(node: random)
        }
    }
