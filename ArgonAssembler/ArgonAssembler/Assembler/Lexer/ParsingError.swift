//
//  ArgonError.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/14.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum ParsingError:Error
    {
    case colonExpectedAfterLabel
    case instructionCodeExpected
    case undefinedInstructionCode
    case rightBraExpected
    case leftBraExpected
    case immediateOrRegisterExpected
    case immediateAlreadyDefined
    case registerAlreadyDefined
    case plusAlreadyUsed
    case percentExpected
    case registerExpected
    case invalidRegister
    }
