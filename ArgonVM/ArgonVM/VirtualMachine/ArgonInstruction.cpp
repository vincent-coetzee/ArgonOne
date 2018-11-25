//
//  ArgonInstruction.cpp
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "ArgonInstruction.hpp"

typedef unsigned long long Word;
typedef Word* WordPointer;
typedef void* Pointer;

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

class ArgonInstruction
    {
    public:
        ArgonInstruction(Word instruction)
            {
            this->instructionWord = instruction;
            };
        
        int mode()
            {
            return((int)((instructionWord & kInstructionMode) >> kInstructionModeShift));
            };
        
        int opcode()
            {
            return((int)((instructionWord & kInstructionCode) >> kInstructionCodeShift));
            };
        
        int register1()
            {
            return((int)((instructionWord & kInstructionRegister1) >> kInstructionRegister1Shift));
            };
        
        int register2()
            {
            return((int)((instructionWord & kInstructionRegister2) >> kInstructionRegister2Shift));
            };
        
        int register3()
            {
            return((int)((instructionWord & kInstructionRegister3) >> kInstructionRegister3Shift));
            };
        
        void setMode(int mode)
            {
            Word newMode = (Word)mode;
            newMode <<= kInstructionModeShift;
            newMode &= kInstructionMode;
            instructionWord |= newMode;
            }
        
        void setCode(int code)
            {
            Word newCode = (Word)code;
            newCode <<= kInstructionCodeShift;
            newCode &= kInstructionCode;
            instructionWord |= newCode;
            }
        
    private:
        Word instructionWord;
    };
