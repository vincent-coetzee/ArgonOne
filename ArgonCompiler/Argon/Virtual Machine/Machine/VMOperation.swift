//
//  VMOperation.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/10/31.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum VMOperation:Int
    {
    case BR
    case BRT
    case BRF
    case GT
    case GTE
    case EQ
    case NEQ
    case LTE
    case LT
    case NOP
    case MOVIR
    case MOVRR
    case MOVAR
    case MOVNR
    case MOVRN
    case AND
    case OR
    case XOR
    case NOT
    case ADD
    case SUB
    case MUL
    case MOD
    case DIV
    case DSP
    case LOAD
    case MAKE
    case PUSH
    case POP
    case ROL
    case ROR
    case RET
    case INC
    case DEC
    case CALL
    case NXT
    case HALT
    case PRIM
    case STORE
    case SPAWN
    
    public var name:String
        {
        switch(self)
            {
            case .HALT:
                return("HALT")
            case .SPAWN:
                return("SPAWN")
            case .STORE:
                return("STORE")
            case .PRIM:
                return("PRIM")
            case .BR:
                return("BR")
            case .BRT:
                return("BRT")
            case .BRF:
                return("BRF")
            case .GT:
                return("GT")
            case .GTE:
                return("GTE")
            case .EQ:
                return("EQ")
            case .NEQ:
                return("NEQ")
            case .LTE:
                return("LTE")
            case .LT:
                return("LT")
            case .NOP:
                return("NOP")
            case .MOVIR:
                return("MOVIR")
            case .MOVRR:
                return("MOVRR")
            case .MOVAR:
                return("MOVAR")
            case .MOVNR:
                return("MOVNR")
            case .MOVRN:
                return("MOVRN")
            case .AND:
                return("AND")
            case .OR:
                return("OR")
            case .XOR:
                return("XOR")
            case .NOT:
                return("NOT")
            case .ADD:
                return("ADD")
            case .SUB:
                return("SUB")
            case .MUL:
                return("MUL")
            case .MOD:
                return("MOD")
            case .DIV:
                return("DIV")
            case .DSP:
                return("DSP")
            case .LOAD:
                return("LOAD")
            case .MAKE:
                return("MAKE")
            case .PUSH:
                return("PUSH")
            case .POP:
                return("POP")
            case .ROL:
                return("ROL")
            case .ROR:
                return("ROR")
            case .INC:
                return("INC")
            case .DEC:
                return("DEC")
            case .CALL:
                return("CALL")
            case .RET:
                return("RET")
            case .NXT:
                return("NXT")
            }
        }
    }
