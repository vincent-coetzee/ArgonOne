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
// The masks for tagging a pointer
//
#define kBitsMask (((Word)7) << ((Word)61))
#define kBitsInteger (((Word)0) << ((Word)61))
#define kBitsFloat (((Word)1) << ((Word)61))
#define kBitsByte (((Word)2) << ((Word)61))
#define kBitsBoolean (((Word)3) << ((Word)61))
#define kBitsObject (((Word)4) << ((Word)61))
#define kBitsDate (((Word)5) << ((Word)61))
#define kBitsHandler (((Word)6) << ((Word)61))


#define kBitsShift ((Word)61)
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
#define kTypeObject (0)
#define kTypeInteger (1)
#define kTypeFloat (2)
#define kTypeString (3)
#define kTypeDate (4)
#define kTypeVector (5)
#define kTypeMap (6)
#define kTypeTree (7)
#define kTypeExtensionBlock (8)
#define kTypeAssociationVector (9)
#define kTypeTraits (10)

#define kMaximumType (10)

//
// Some miscellaneous numbers
//
#define kCollectionGrowthFactor 9/5
//
// Exceptions that can occur in the VM
//
enum RuntimeException
    {
    outOfMemory
    };
//
// Instruction Mode enum, ensures that the correct
// modes are tested and used.
//
enum InstructionMode
    {
    regular,
    skipped,
    address,
    leftIndirect,
    rightIndirect,
    immediate,
    registers,
    indirect
    };
//
// An enum of all the actual mnemonics of the opcodes supported
// by the Argon VM.
//
enum InstructionCode
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
    };

#endif /* ArgonTypes_hpp */
