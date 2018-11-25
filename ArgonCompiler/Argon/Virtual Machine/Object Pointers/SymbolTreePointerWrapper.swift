//
//  TreePointerWrapper.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/21.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class SymbolTreePointerWrapper:InstancePointerWrapper
    {
    fileprivate class Node
        {
        var nodeIndex:Int32 = 0
        var symbolPointer:Pointer = wordAsPointer(0)
        var left:Node?
        var right:Node?
        var leftIndex:Int32 = 0
        var rightIndex:Int32 = 0
        var treePointer = wordAsPointer(0)
        var wasLoaded = false
        
        init(treePointer:Pointer,nodeIndex:Int32,symbolPointer:Pointer)
            {
            self.nodeIndex = nodeIndex
            self.treePointer = treePointer
            self.symbolPointer = symbolPointer
            }
        
        init(treePointer:Pointer,nodeIndex:Int32)
            {
            self.nodeIndex = nodeIndex
            self.treePointer = treePointer
            symbolPointer = pointerAtIndexAtPointer(nodeIndex,treePointer)
            leftIndex = Int32(wordAtIndexAtPointer(nodeIndex+1,treePointer))
            rightIndex = Int32(wordAtIndexAtPointer(nodeIndex+2,treePointer))
            }
        
        func find(symbol:String) -> Pointer?
            {
            let localSymbol = SymbolPointerWrapper(symbolPointer).symbol
            if  localSymbol == symbol
                {
                return(symbolPointer)
                }
            self.loadIfNeeded()
            if symbol < localSymbol
                {
                return(left?.find(symbol:symbol))
                }
            else
                {
                return(right?.find(symbol:symbol))
                }
            }
        
        func add(symbol:String,at index:Int32,in memory:Memory) throws -> Pointer
            {
            let localString = StringPointerWrapper(symbolPointer).string
            if localString == symbol
                {
                return(symbolPointer)
                }
            self.loadIfNeeded()
            if symbol < localString
                {
                if left == nil
                    {
                    let newPointer = try memory.allocate(symbol: symbol)
                    left = Node(treePointer:treePointer,nodeIndex:index,symbolPointer:newPointer)
                    print("Node is \(localString)")
                    print("Saving \(symbol) on left at \(index)")
                    leftIndex = index
                    self.write()
                    left!.write()
                    return(newPointer)
                    }
                else
                    {
                    return(try left!.add(symbol:symbol,at:index,in: memory))
                    }
                }
            else
                {
                if right == nil
                    {
                    let newPointer = try memory.allocate(symbol: symbol)
                    right = Node(treePointer:treePointer,nodeIndex:index,symbolPointer:newPointer)
                    print("Node is \(localString)")
                    print("Saving \(symbol) on right at \(index)")
                    rightIndex = index
                    self.write()
                    right!.write()
                    return(newPointer)
                    }
                else
                    {
                    return(try right!.add(symbol:symbol,at:index,in: memory))
                    }
                }
            }
        
        private func loadIfNeeded()
            {
            if !wasLoaded
                {
                if leftIndex != 0
                    {
                    left = Node(treePointer:treePointer,nodeIndex:leftIndex)
                    }
                if rightIndex != 0
                    {
                    right = Node(treePointer:treePointer,nodeIndex:rightIndex)
                    }
                wasLoaded = true
                }
            }
        
        func walk()
            {
            self.loadIfNeeded()
            self.left?.walk()
            print(StringPointerWrapper(symbolPointer).string)
            self.right?.walk()
            }
        
        func write()
            {
            setPointerAtIndexAtPointer(symbolPointer,nodeIndex,treePointer)
            setWordAtIndexAtPointer(Word(leftIndex),nodeIndex+1,treePointer)
            setWordAtIndexAtPointer(Word(rightIndex),nodeIndex+2,treePointer)
            }
        }
    
    public static let kHeaderIndex:Int32 = 0
    public static let kTraitsIndex:Int32 = 1
    public static let kMonitorIndex:Int32 = 2
    public static let kNodeCountIndex:Int32 = 3
    public static let kNodeCapacityIndex:Int32 = 4
    public static let kNextNodeIndexIndex:Int32 = 5
    public static let kRootNodeIndex:Int32 = 6
    
    public static let kFixedSlotCount:Int = 7
    
    public var count:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(SymbolTreePointerWrapper.kNodeCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),SymbolTreePointerWrapper.kNodeCountIndex,self.pointer)
            }
        }
    
    public var nextNodeIndex:Int32
        {
        get
            {
            return(Int32(wordAtIndexAtPointer(SymbolTreePointerWrapper.kNextNodeIndexIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),SymbolTreePointerWrapper.kNextNodeIndexIndex,self.pointer)
            }
        }
    
    fileprivate var rootNode:Node?
        {
        get
            {
            let rootIndex = Int32(wordAtIndexAtPointer(SymbolTreePointerWrapper.kRootNodeIndex,self.pointer))
            if rootIndex == 0
                {
                return(nil)
                }
            let node = Node(treePointer:self.pointer,nodeIndex:rootIndex)
            return(node)
            }
        set
            {
            if let value = newValue
                {
                let nextIndex = self.nextNodeIndex
                value.nodeIndex = nextIndex
                value.write()
                setWordAtIndexAtPointer(Word(nextIndex),SymbolTreePointerWrapper.kRootNodeIndex,self.pointer)
                self.nextNodeIndex = nextIndex + 3
                }
            else
                {
                setWordAtIndexAtPointer(0,SymbolTreePointerWrapper.kRootNodeIndex,self.pointer)
                }
            }
        }
    
    public func find(symbol:String) -> Pointer?
        {
        return(self.rootNode?.find(symbol:symbol))
        }
    
    @discardableResult
    public func add(symbol:String,memory:Memory) throws -> Pointer
        {
        self.count = self.count + 1
        let nextNodeIndex = self.nextNodeIndex
        var newPointer:Pointer
        if let root = self.rootNode
            {
            newPointer = try root.add(symbol:symbol,at:nextNodeIndex,in:memory)
            }
        else
            {
            newPointer = try memory.allocate(symbol: symbol)
            self.rootNode = Node(treePointer:self.pointer,nodeIndex: nextNodeIndex,symbolPointer:newPointer)

            }
        self.nextNodeIndex = nextNodeIndex + 3
        return(newPointer)
        }
    
    public func walk()
        {
        self.rootNode?.walk()
        }
    }
