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
// Tagging and untagging pointers
//
#define untaggedPointer(p) ((Pointer)((((Word)p) & ~kBitsMask)))
#define taggedPointer(p,t) ((Pointer)((((Word)p) & ~kBitsMask) | t))
#define taggedStringPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsString))
#define taggedSymbolPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsSymbol))
#define taggedTraitsPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsTraits))
#define tagggedDatePointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsDate))
#define taggedMapPointer(p) (void*)((((Word)p) & ~kBitsMask) | kBitsMap)
#define taggedHandlerPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsHandler))
#define taggedMethodPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsMethod))
#define taggedCodeBlockPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsCodeBlock))
#define taggedExtensionBlockPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsExtensionBlock))
#define taggedVectorPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsVector))
#define taggedClosurePointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsClosure))
#define taggedObjectPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsObject))
#define taggedBoolean(b) (kBitsBoolean | b)
#define taggedByte(b) (kBitsByte | b)
#define taggedFloat(f) (kBitsFloat | f)
#define taggedInteger(i) (kBitsInteger | i)
#define taggedDate(d) (kBitsDate | d)
#define untaggedByte(b) ((unsigned char)value & 255)
#define untaggedBoolean(b) (b & 1)
#define untaggedDate(d) (d & ~kBitsMask)
#define untaggedFloat(f) (f & ~kBitsFloat)
#define untaggedInteger(i) (i & ~kBitsMask)
//
// Accessing words and pointers from
// pointers.
//
#define wordAtIndexAtPointer(index,pointer) (*(((WordPointer)untaggedPointer(pointer)) + index))
#define pointerAtIndexAtPointer(index,pointer) (*((Pointer*)(((WordPointer)untaggedPointer(pointer)) + index)))
#define setWordAtIndexAtPointer(word,index,pointer) *(((WordPointer)untaggedPointer(pointer))+index) = word
#define setPointerAtIndexAtPointer(newPointer,index,pointer) *((Pointer*)(((WordPointer)untaggedPointer(pointer))+index)) = newPointer
#define wordAtPointer(p) (*((WordPointer)untaggedPointer(p)))
#define pointerAtPointer(p) (*((Pointer*)untaggedPointer(p)))
#define setWordAtPointer(w,p) *((WordPointer)untaggedPointer(p)) = w
#define setPointerAtPointer(sp,p) *((Pointer*)untaggedPointer(p)) = sp
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
// Instruction field constants
//
#define kModeRegular 0
#define kModeDouble 1
#define kModeAddress 2
#define kModeLeftIndirect 3
#define kModeRightIndirect 4
#define kModeImmediate 5
#define kModeRegister 6
#define kModeIndirect 7
//
// Extension Block slot indices
//
#define kExtensionBlockHeaderIndex (0)
#define kExtensionBlockTraitsIndex (1)
#define kExtensionBlockMonitorIndex (2)
#define kExtensionBlockCountIndex (3)
#define kExtensionBlockCapacityIndex (4)
#define kExtensionBlockBytesIndex (5)

#define kExtensionBlockFixedSlotCount (6)
//
// Map slot indices
//
#define kMapHeaderIndex (0)
#define kMapTraitsIndex (1)
#define kMapMonitorIndex (2)
#define kMapCountIndex (3)
#define kMapCapacityIndex (4)
#define kMapHashbucketCountIndex (5)

#define kMapFixedSlotCount (6)

#define kMapHashPrime (199)
#define kMapBucketPrime (109)
//
// Vector slot indices
//
#define kVectorHeaderIndex (0)
#define kVectorTraitsIndex (1)
#define kVectorMonitorIndex (2)
#define kVectorCountIndex (3)
#define kVectorCapacityIndex (4)
#define kVectorExtensionBlockIndex (5)

#define kVectorFixedSlotCount (6)
//
// String slot indices
//
#define kStringHeaderIndex 0
#define kStringTraitsIndex 1
#define kStringMonitorIndex 2
#define kStringCountIndex 3
#define kStringExtensionBlockIndex 4
#define kStringFixedSlotCount 5
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
