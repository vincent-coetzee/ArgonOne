//
//  ArgonThreadStackFrame.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/07.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class ArgonThreadStackFrame:ArgonStackFrame
    {
    public override var isThreadFrame:Bool
        {
        return(true)
        }
    }
