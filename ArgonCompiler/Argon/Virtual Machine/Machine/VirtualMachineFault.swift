//
//  VirtualMachineFault.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/09/20.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public enum VirtualMachineFault:Error
    {
    case encodedCountExpected
    case invalidInstruction
    case invalidRegister
    case invalidAddress
    case invalidSlotIndex
    case invalidIndex
    case systemFault
    case outOfMemory
    case notImplemented
    case invalidLabel
    case assemblerClosed
    case assemblerOpen
    case undefinedGenericMethod(String)
    case instructionExtensionMissing
    case failedToGrow
    }

public enum VirtualMachineSignal:Int,Error
    {
    case misalignedWrite
    case outOfMemory
    case sizeOverflow
    case invalidSlot
    case sharedMemoryError
    case invalidSlotCount
    case invalidType
    case invalidAddress
    case objectMemoryMissing
    case invalidInstruction
    case dispatchFailed
    case unresolvedImport
    }

public enum CompilerError:Error
    {
    case invalidTraits
    case registerAllocationFailed
    case noLocation
    case notImplemented
    case noBasicBlocks
    case noThreeAddressInstructions
    case invalidAssignInstruction
    case temporaryNotInRegister
    case unsupportedOperandType
    case invalidLValue
    case invalidRValue
    case callWithoutClosure
    case stackFrameMissing
    case patternVariableMissing
    case invalidOperandType
    }

public enum LinkerError:Error
    {
    case relocationTraitsNotInstalled
    case opcodeNotImplemented
    }

public enum RuntimeError:Error
    {
    case invalidPrimitive
    case librariesCanNotRun
    }
