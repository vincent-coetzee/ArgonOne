//
//  ArgonOperatorMethodNode.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum ArgonOperatorKind
    {
    case unknown
    case prefix
    case postfix
    case infix
    }

public class ArgonOperatorMethodNode:ArgonMethodNode
    {
    public private(set) var operatorKind:ArgonOperatorKind = .unknown
    public private(set) var operatorString:String = ""
    
    public override var isOperatorBased:Bool
        {
        return(true)
        }
    }
