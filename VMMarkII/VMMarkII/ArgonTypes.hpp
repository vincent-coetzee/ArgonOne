//
//  ArgonTypes.h
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonTypes_hpp
#define ArgonTypes_hpp

typedef unsigned long long Word;
typedef Word* WordPointer;
typedef void* Pointer;

//
// Some sizes
//
#define kWordSize (sizeof(Word))
#define kObjectBaseSizeInWords (8)
//
// Masks for the condition flag in a ThreadContext
//
#define kConditionE (128)
#define kConditionEShift = ((Word)7)
#define kConditionGTE (64)
#define kConditionGTEShift = ((Word)6)
#define kConditionGT (32)
#define kConditionGTShift = ((Word)5)
#define kConditionLTE (16)
#define kConditionLTEShift = ((Word)4)
#define kConditionLT (8)
#define kConditionLTShift = ((Word)3)
#define kConditionZ (4)
#define kConditionZShift = ((Word)2)
//
// The masks for tagging a pointer
//
#define kBitsMask (((Word)15) << ((Word)59))
#define kBitsInteger (((Word)0) << ((Word)59))
#define kBitsFloat (((Word)1) << ((Word)59))
#define kBitsByte (((Word)2) << ((Word)59))
#define kBitsBoolean (((Word)3) << ((Word)59))
#define kBitsObject (((Word)4) << ((Word)59))
#define kBitsDate (((Word)5) << ((Word)59))
#define kBitsHandler (((Word)6) << ((Word)59))
#define kBitsVector (((Word)7) << ((Word)59))
#define kBitsMap (((Word)8) << ((Word)59))
#define kBitsCodeBlock (((Word)9) << ((Word)59))
#define kBitsExtensionBlock (((Word)10) << ((Word)59))
#define kBitsMethod (((Word)11) << ((Word)59))
#define kBitsClosure (((Word)12) << ((Word)59))
#define kBitsTraits (((Word)13) << ((Word)59))
#define kBitsString (((Word)14) << ((Word)59))
#define kBitsSymbol (((Word)15) << ((Word)59))

//
// Special register numbers
//
#define kRegisterNone 0
#define kRegisterBP 1
#define kRegisterSP 2
#define kRegisterIP 3
#define kRegisterST 4
#define kRegisterLP 5


//
// Integers defining the types of objects
// that are known to the system.
//
#define kTypeObject 0
#define kTypeInteger 1
#define kTypeFloat 2
#define kTypeString 3
#define kTypeDate 4
#define kTypeChar 5
#define kTypeVector 6
#define kTypeMap 7
#define kTypeTree 8
#define kTypeExtensionBlock (9)
#define kTypeAssociationVector (10)


//
// Exceptions that can occur in the VM
//
typedef enum _RuntimeException
    {
    outOfMemory
    }
    RuntimeException;
//
// Instruction Mode enum, ensures that the correct
// modes are tested and used.
//
typedef enum _InstructionMode
    {
    regular,
    skipped,
    address,
    leftIndirect,
    rightIndirect,
    immediate,
    registers,
    indirect
    }
    InstructionMode;
//
// An enum of all the actual mnemonics of the opcodes supported
// by the Argon VM.
//
typedef enum _InstructionCode
    {
    BR,
    BRT,
    BRF,
    GT,
    GTE,
    EQ,
    NEQ,
    LTE,
    LT,
    NOP,
    MOVIR,
    MOVRR,
    MOVAR,
    MOVNR,
    MVRN,
    AND,
    OR,
    XOR,
    NOT,
    ADD,
    SUB,
    MUL,
    MOD,
    DIV,
    DISP,
    LOAD,
    MAKE,
    PUSH,
    POP,
    ROL,
    ROR,
    RET,
    INC,
    DEC,
    CALL,
    NEXT,
    HALT,
    PRIM,
    STORE,
    SPAWN,
    SIG,
    HAND,
    RES
    }
    InstructionCode;

#endif /* ArgonTypes_hpp */
