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
    
    public private(set) var booleanTraits:ArgonSystemTraitsNode
    public private(set) var integerTraits:ArgonSystemTraitsNode
    public private(set) var errorTraits:ArgonSystemTraitsNode
    public private(set) var voidTraits:ArgonSystemTraitsNode
    public private(set) var stringTraits:ArgonSystemTraitsNode
    public private(set) var floatTraits:ArgonSystemTraitsNode
    public private(set) var closureTraits:ArgonSystemTraitsNode
    public private(set) var symbolTraits:ArgonSystemTraitsNode
    public private(set) var vectorTraits:ArgonSystemTraitsNode
    public private(set) var anyTraits:ArgonSystemTraitsNode
    public private(set) var behaviorTraits:ArgonSystemTraitsNode
    public private(set) var traitsTraits:ArgonSystemTraitsNode
    public private(set) var doubleTraits:ArgonSystemTraitsNode
    public private(set) var polymorphicArgumentTraits:ArgonSystemTraitsNode
    public private(set) var handlerBlockTraits:ArgonSystemTraitsNode
    public private(set) var mapTraits:ArgonSystemTraitsNode
    public private(set) var dateTraits:ArgonSystemTraitsNode
    
    public override init(name:ArgonName)
        {
        voidTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Void"))
        voidTraits.asArgonTraits()
        polymorphicArgumentTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::PolymorphicArgument"))
        polymorphicArgumentTraits.parents = [voidTraits]
        polymorphicArgumentTraits.asArgonTraits()
        behaviorTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Behaviour"))
        behaviorTraits.asArgonTraits()
        handlerBlockTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::HandlerBlock"))
        handlerBlockTraits.parents = [behaviorTraits]
        handlerBlockTraits.asArgonTraits()
        traitsTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::TraitsTraits"))
        anyTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Any"))
        anyTraits.parents = [behaviorTraits]
        anyTraits.asArgonTraits()
        errorTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Error"))
        errorTraits.parents = [behaviorTraits]
        errorTraits.asArgonTraits()
        closureTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Closure"))
        closureTraits.parents = [behaviorTraits]
        closureTraits.asArgonTraits()
        let method = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Method"))
        method.parents = [behaviorTraits]
        method.asArgonTraits()
        let genericMethod = ArgonSystemTraitsNode(fullName: ArgonName("Argon::GenericMethod"))
        genericMethod.parents = [method]
        genericMethod.asArgonTraits()
        let traits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Traits"))
        traits.parents = [behaviorTraits]
        traits.asArgonTraits()
        traitsTraits.parents = [traits]
        traitsTraits.asArgonTraits()
        let collection = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Collection"))
        collection.parents = [traits]
        collection.asArgonTraits()
        let vector = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Vector"))
        vector.parents = [collection]
        vector.asArgonTraits()
        vectorTraits = vector
        let map = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Map"))
        map.parents = [collection]
        map.asArgonTraits()
        mapTraits = map
        stringTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::String"))
        stringTraits.parents = [vector]
        stringTraits.asArgonTraits()
        let number = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Number"))
        number.parents = [traits]
        number.asArgonTraits()
        integerTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Integer"))
        integerTraits.parents = [number]
        integerTraits.asArgonTraits()
        symbolTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Symbol"))
        symbolTraits.parents = [stringTraits]
        symbolTraits.asArgonTraits()
        booleanTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Boolean"))
        booleanTraits.parents = [symbolTraits]
        booleanTraits.asArgonTraits()
        floatTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Float"))
        doubleTraits = ArgonSystemTraitsNode(fullName: ArgonName("Argon::Double"))
        doubleTraits.parents = [number]
        doubleTraits.asArgonTraits()
        floatTraits.parents = [number]
        floatTraits.asArgonTraits()
        map.addSystemSlot(name:"header",offset:0,traits:integerTraits)
        map.addSystemSlot(name:"traits",offset:8,traits:traitsTraits)
        map.addSystemSlot(name:"monitor",offset:16,traits:behaviorTraits)
        map.addSystemSlot(name:"count",offset:24,traits:integerTraits)
        map.addSystemSlot(name:"capacity",offset:32,traits:integerTraits)
        stringTraits.addSystemSlot(name:"header",offset:0,traits:integerTraits)
        stringTraits.addSystemSlot(name:"traits",offset:8,traits:traitsTraits)
        stringTraits.addSystemSlot(name:"monitor",offset:16,traits:behaviorTraits)
        stringTraits.addSystemSlot(name:"count",offset:24,traits:integerTraits)
        stringTraits.addSystemSlot(name:"extensionBlock",offset:32,traits:behaviorTraits)
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
