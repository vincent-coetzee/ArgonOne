//
//  ThreeAddressBasicBlockDAG.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/23.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class BasicBlockDAG
    {
    public var nodes:[InnerNode] = []
    
    public var hasCommonSubexpression:Bool
        {
        for node in nodes
            {
            if node.hasCommonSubexpression
                {
                return(true)
                }
            }
        return(false)
        }
    
    public var depth:Int
        {
        var depth = 0
        for node in nodes
            {
            depth = max(depth,node.depth)
            }
        return(depth)
        }
    
    public func labelWithRequiredRegisterCount()
        {
        for node in nodes
            {
            node.labelWithRequiredRegisterCount()
            }
        }
    
    public func splitCommonSubexpressions()
        {
        for node in nodes
            {
            if node.hasCommonSubexpression
                {
                node.splitCommonSubexpressions()
                }
            }
        }
    
    public func add(node:InnerNode)
        {
        nodes.append(node)
        }
    
    public func operand(for address:ThreeAddress) -> Node
        {
        for node in nodes
            {
            if let value = node.operand(for:address)
                {
                return(value)
                }
            }
        return(LeafNode(address.name.string))
        }
    
    public func dump()
        {
        for node in nodes
            {
            node.dump()
            }
        }
    
    public func node(with label: String) -> Node?
        {
        for node in nodes
            {
            if let innerNode = node.node(with: label)
                {
                return(innerNode)
                }
            }
        return(nil)
        }
    
    public func inner(for operation:ThreeAddressOperation,_ lhs:Node?,_ rhs:Node?) -> InnerNode?
        {
        for node in nodes
            {
            if let aNode = node.inner(for: operation,lhs,rhs)
                {
                return(aNode)
                }
            }
        return(nil)
        }
    }

extension BasicBlockDAG
    {
    public class Node
        {
        public var labels:[String] = []
        public var parents:[Node] = []
        public var registerLabel:Int = 0
        
        public var depth:Int
            {
            return(0)
            }
        
        public var isLeaf:Bool
            {
            return(false)
            }
        
        public var hasCommonSubexpression:Bool
            {
            if parents.count > 1
                {
                return(true)
                }
            return(false)
            }
        
        public static func ==(lhs:Node,rhs:Node) -> Bool
            {
            if type(of: lhs) != type(of: rhs)
                {
                return(false)
                }
            if lhs is LeafNode
                {
                let lhsLeaf = lhs as! LeafNode
                let rhsLeaf = rhs as! LeafNode
                return(lhsLeaf == rhsLeaf)
                }
            if lhs is InnerNode
                {
                let lhsInner = lhs as! InnerNode
                let rhsInner = rhs as! InnerNode
                return(lhsInner == rhsInner)
                }
            return(false)
            }

        public func labelWithRequiredRegisterCount()
            {
            }
        
        public func makePrivateCopy(of node:Node)
            {
            }
        
        public func copy() -> Node
            {
            fatalError("Should not be called")
            }
        
        public func splitCommonSubexpressions()
            {
            if parents.count > 1
                {
                for parent in parents
                    {
                    parent.makePrivateCopy(of: self)
                    }
                }
            }
        
        public func node(with aLabel: String) -> Node?
            {
            for label in labels
                {
                if label == aLabel
                    {
                    return(self)
                    }
                }
            return(nil)
            }
        
        public func add(label:String)
            {
            self.labels.append(label)
            }
        
        public func remove(label:String)
            {
            labels.removeAll(where: {$0 == label})
            }
        
        public func inner(for operation:ThreeAddressOperation,_ lhs:Node?,_ rhs:Node?) -> InnerNode?
            {
            return(nil)
            }
        
        public func operand(for:ThreeAddress) -> Node?
            {
            return(nil)
            }
        
        public func dump()
            {
            fatalError("Should not be called on this class")
            }
        }
    }

extension Optional where Wrapped == BasicBlockDAG.LeafNode
    {
    static func ==(lhs:Optional,rhs:Optional) -> Bool
        {
        return(lhs == nil && rhs == nil || (lhs != nil && rhs != nil && (lhs! == rhs!)))
        }
    }

extension Optional where Wrapped == BasicBlockDAG.Node
    {
    static func ==(lhs:Optional,rhs:Optional) -> Bool
        {
        return(lhs == nil && rhs == nil || (lhs != nil && rhs != nil && (lhs! == rhs!)))
        }
    }

extension Optional where Wrapped == BasicBlockDAG.InnerNode
    {
    static func ==(lhs:Optional,rhs:Optional) -> Bool
        {
        return(lhs == nil && rhs == nil || (lhs != nil && rhs != nil && (lhs! == rhs!)))
        }
    }

extension BasicBlockDAG
    {
    public class InnerNode:Node
        {
        public var lhs:Node?
        public var rhs:Node?
        public let operation:ThreeAddressOperation
        
        public override var hasCommonSubexpression:Bool
            {
            if lhs?.hasCommonSubexpression ?? false
                {
                return(true)
                }
            else if rhs?.hasCommonSubexpression ?? false
                {
                return(true)
                }
            return(false)
            }
        
        public override var depth:Int
            {
            return(max((lhs?.depth ?? 1)+1,(rhs?.depth ?? 1)+1))
            }
        
        public static func ==(lhs:InnerNode,rhs:InnerNode) -> Bool
            {
            return(lhs.operation == rhs.operation && lhs.lhs == rhs.lhs || lhs.rhs == rhs.rhs)
            }
        
        init(_ operation:ThreeAddressOperation,_ lhs:Node?,_ rhs:Node?)
            {
            self.operation = operation
            super.init()
            self.lhs = lhs
            lhs?.parents.append(self)
            self.rhs = rhs
            rhs?.parents.append(self)
            }
        
        public override func labelWithRequiredRegisterCount()
            {
            if lhs != nil
                {
                lhs!.isLeaf ? lhs!.registerLabel = 1 : lhs!.labelWithRequiredRegisterCount()
                }
            if rhs != nil
                {
                rhs!.isLeaf ? rhs!.registerLabel = 0 : rhs!.labelWithRequiredRegisterCount()
                }
            let leftLabel = lhs?.registerLabel ?? 1
            let rightLabel = rhs?.registerLabel ?? 0
            self.registerLabel = leftLabel == rightLabel ? leftLabel + 1 : max(leftLabel,rightLabel)
            }
        
        public override func splitCommonSubexpressions()
            {
            if parents.count > 1
                {
                for parent in parents
                    {
                    parent.makePrivateCopy(of: self)
                    }
                }
            else
                {
                lhs?.splitCommonSubexpressions()
                rhs?.splitCommonSubexpressions()
                }
            }
        
        public override func copy() -> Node
            {
            let newNode = InnerNode(operation,lhs?.copy(),rhs?.copy())
            newNode.labels = self.labels
            return(newNode)
            }
        
        public override func makePrivateCopy(of node:Node)
            {
            if node == self.lhs
                {
                self.lhs = node.copy()
                }
            else if node == self.rhs
                {
                self.rhs = node.copy()
                }
            }
        
        public override func inner(for operation:ThreeAddressOperation,_ lhs:Node?,_ rhs:Node?) -> InnerNode?
            {
            if self.operation == operation && lhs == self.lhs && rhs == self.rhs
                {
                return(self)
                }
            else if let node = lhs?.inner(for: operation,lhs,rhs)
                {
                return(node)
                }
            else if let node = rhs?.inner(for: operation,lhs,rhs)
                {
                return(node)
                }
            else
                {
                return(nil)
                }
            }

        public override func operand(for address:ThreeAddress) -> Node?
            {
            if let node = lhs?.operand(for: address)
                {
                return(node)
                }
            if let node = rhs?.operand(for: address)
                {
                return(node)
                }
            return(nil)
            }
        }
    }

extension BasicBlockDAG
    {
    public class LeafNode:Node
        {
        public static func ==(lhs:LeafNode,rhs:LeafNode) -> Bool
            {
            return(lhs.labels == rhs.labels)
            }
        
        public override var isLeaf:Bool
            {
            return(true)
            }
        
        init(_ label:String)
            {
            super.init()
            self.labels.append(label)
            }
        
        public override var depth:Int
            {
            return(1)
            }
        
        public override func copy() -> Node
            {
            let newNode = LeafNode(self.labels.first!)
            newNode.labels = self.labels
            return(newNode)
            }
        
        public override func operand(for address:ThreeAddress) -> Node?
            {
            if self.labels.contains(address.name.string)
                {
                return(self)
                }
            return(nil)
            }
        }
    }
