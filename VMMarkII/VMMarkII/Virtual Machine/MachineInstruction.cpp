//
//  ArgonInstruction.cpp
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "MachineInstruction.hpp"
#include "CobaltTypes.hpp"
#include <stdlib.h>
#include "String.hpp"

#define kInstructionReserved (((Word)4) << ((Word)60))
#define kInstructionMode (((Word)15) << ((Word)56))
#define kInstructionCode (((Word)127) << ((Word)49))
#define kInstructionRegister1 (((Word)63) << ((Word)43))
#define kInstructionRegister2 (((Word)63) << ((Word)36))
#define kInstructionRegister3 (((Word)63) << ((Word)30))
#define kInstructionImmediateSign (((Word)1) << ((Word)29))
#define kInstructionImmediate (((Word)536870911) << ((Word)0))

#define kInstructionModeShift ((Word)56)
#define kInstructionCodeShift ((Word)49)
#define kInstructionRegister1Shift ((Word)(43))
#define kInstructionRegister2Shift ((Word)(36))
#define kInstructionRegister3Shift ((Word)(30))
#define kInstructionImmediateSignShift ((Word)(29))
#define kInstructionImmediateShift ((Word)(0))


MachineInstruction::MachineInstruction(Word instruction)
    {
    this->instructionWord = instruction;
    };
        
InstructionMode MachineInstruction::mode()
    {
    return(InstructionMode((instructionWord & kInstructionMode) >> kInstructionModeShift));
    };
        
InstructionCode MachineInstruction::code()
    {
    return((InstructionCode((instructionWord & kInstructionCode) >> kInstructionCodeShift)));
    };
        
int MachineInstruction::register1()
    {
    return((int)((instructionWord & kInstructionRegister1) >> kInstructionRegister1Shift));
    };
        
int MachineInstruction::register2()
    {
    return((int)((instructionWord & kInstructionRegister2) >> kInstructionRegister2Shift));
    };
        
int MachineInstruction::register3()
    {
    return((int)((instructionWord & kInstructionRegister3) >> kInstructionRegister3Shift));
    };

Word MachineInstruction::address()
    {
    return(addressWord);
    };

void MachineInstruction::setAddress(Word word)
    {
    addressWord = word;
    };

int MachineInstruction::immediate()
    {
    int immediate = (int)((instructionWord & kInstructionImmediate) >> kInstructionImmediateShift);
    if (this->immediateSign())
        {
        immediate *= -1;
        }
    return(immediate);
    };
        
int MachineInstruction::immediateSign()
    {
    return((int)((instructionWord & kInstructionImmediateSign) >> kInstructionImmediateSignShift));
    };
        
void MachineInstruction::setMode(InstructionMode aMode)
    {
    Word newMode = (Word)aMode;
    newMode <<= kInstructionModeShift;
    newMode &= kInstructionMode;
    this->instructionWord |= newMode;
    }
        
void MachineInstruction::setCode(InstructionCode code)
    {
    Word newCode = (Word)code;
    newCode <<= kInstructionCodeShift;
    newCode &= kInstructionCode;
    instructionWord |= newCode;
    }
        
void MachineInstruction::setRegister1(int aRegister)
    {
    Word newRegister = (Word)aRegister;
    newRegister <<= kInstructionRegister1Shift;
    newRegister &= kInstructionRegister1;
    instructionWord |= newRegister;
    }
        
void MachineInstruction::setRegister2(int aRegister)
    {
    Word newRegister = (Word)aRegister;
    newRegister <<= kInstructionRegister2Shift;
    newRegister &= kInstructionRegister2;
    instructionWord |= newRegister;
    }

void MachineInstruction::setRegister3(int aRegister)
    {
    Word newRegister = (Word)aRegister;
    newRegister <<= kInstructionRegister3Shift;
    newRegister &= kInstructionRegister3;
    instructionWord |= newRegister;
    }

void MachineInstruction::setImmediateSign(int sign)
    {
    Word newSign = (Word)sign;
    newSign <<= kInstructionImmediateSignShift;
    newSign &= kInstructionImmediateSign;
    instructionWord |= newSign;
    }

void MachineInstruction::setImmediate(int immediate)
    {
    int sign = immediate < 1 ? 1 :0;
    Word newImmediate = (Word)abs(immediate);
    newImmediate <<= kInstructionImmediateShift;
    newImmediate &= kInstructionImmediate;
    instructionWord |= newImmediate;
    if (sign)
        {
        this->setImmediateSign(sign);
        }
    };

String MachineInstruction::bitStringFor(Word word)
    {
    Word bitPattern = (unsigned long)9223372036854775808UL;
    char bytes[200];
    char*  string = bytes;
    for (int index=0;index<64;index++)
        {
        *string++ = (word & bitPattern ) == bitPattern ? '1' : '0';
        if (index > 0 && (index % 8) == 0)
            {
            *string++ = ' ';
            }
        bitPattern >>= 1;
        }
    *string = 0;
    return(String(bytes));
    }

String MachineInstruction::bitStringFor(Pointer pointer)
    {
    Word word = (Word)pointer;;
    Word bitPattern = (unsigned long)9223372036854775808UL;
    char bytes[200];
    char* string = bytes;
    for (int index=0;index<64;index++)
        {
        *string++ = (word & bitPattern ) == bitPattern ? '1' : '0';
        if (index > 0 && (index % 8) == 0)
            {
            *string++ = ' ';
            }
        bitPattern >>= 1;
        }
    *string = 0;
    return(String(bytes));
    }
