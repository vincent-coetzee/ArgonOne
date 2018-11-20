//
//  ArgonBitFieldSet.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonBitFieldSet:ArgonBitSet
    {
    
    public static let headerSet = ArgonBitFieldSet(count: 64,fields: [BitField("flags",0,8),
                                                            BitField("typeFlags",8,8),
                                                            BitField("extraWordCount",48,12),
                                                            BitField("generation",24,8),
                                                            BitField("forwarded",23,1),
                                                            BitField("slotCount",32,16),
                                                            BitField("headerTag",60,3)])
    internal struct BitField
        {
        let name:String
        let index:Int
        let length:Int
        var mask:Word = 0
        var lowerBitsMask:UInt64 = 0
        
        init(_ name:String,_ index:Int,_ length:Int)
            {
            self.name = name
            self.index = index
            self.length = length
            createMask()
            }
    
        
        private mutating func createMask()
            {
            var mask:UInt64 = 1
            var value:UInt64 = 0
            for _ in 1...length
                {
                value |= mask
                mask <<= 1
                }
            self.lowerBitsMask = value
            value = value << index
            self.mask = value
            }
        }
    
    private var fields:[String:BitField] = [:]
    
    override init(count:Int)
        {
        super.init(count:count)
        }
    
    init(count:Int,fields:[BitField])
        {
        for field in fields
            {
            self.fields[field.name] = field
            }
        super.init(count:count)
        }
    
    public func addField(named:String,index:Int,length:Int)
        {
        fields[named] = BitField(named,index,length)
        }
    
    public func setField(named:String,to:UInt)
        {
        guard let field = fields[named] else
            {
            return
            }
        let maskedValue = UInt64(to) & field.lowerBitsMask
        self.setBit(pattern:UInt(maskedValue),at:field.index)
        }
    
    public func setField(named:String,to:Int)
        {
        self.setField(named:named,to:UInt(to))
        }
    
    public func setField(named:String,to:String)
        {
        let value = self.valueOfBitString(to)
        self.setField(named:named,to:UInt(value))
        }
    
    public func valueOfField(named:String) -> UInt64
        {
        guard let field = fields[named] else
            {
            return(1)
            }
        let value = self.bitPattern(at: field.index...field.index + field.length - 1)
        return(UInt64(value))
        }
    }
