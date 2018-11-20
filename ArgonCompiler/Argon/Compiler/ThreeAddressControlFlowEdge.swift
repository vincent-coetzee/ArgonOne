//
//  ThreeAddressControlflowEdge.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/22.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct ThreeAddressControlFlowEdge
    {
    public weak var fromBlock:ThreeAddressBasicBlock?
    public weak var toBlock:ThreeAddressBasicBlock?
    
    init(from:ThreeAddressBasicBlock,to:ThreeAddressBasicBlock)
        {
        self.fromBlock = from
        self.toBlock = to
        }
    
    public func setNodeEdges()
        {
        fromBlock?.outgoingEdge = self
        toBlock?.incomingEdges.append(self)
        }
    }
