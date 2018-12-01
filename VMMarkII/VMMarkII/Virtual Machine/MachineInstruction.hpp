//
//  ArgonInstruction.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonInstruction_hpp
#define ArgonInstruction_hpp

#include <stdio.h>
#include "CobaltTypes.hpp"
#include "String.hpp"

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

class MachineInstruction
    {
    public:
        MachineInstruction(Word instruction);
        ~MachineInstruction();
        InstructionMode mode();
        void setMode(InstructionMode);
        InstructionCode code();
        void setCode(InstructionCode);
        int register1();
        void setRegister1(int);
        int register2();
        void setRegister2(int);
        int register3();
        void setRegister3(int);
        int immediate();
        void setImmediate(int);
        int immediateSign();
        void setImmediateSign(int);
        Word address();
        void setAddress(Word);
        static String bitStringFor(Pointer pointer);
        static String bitStringFor(Word word);
    private:
        Word instructionWord;
        Word addressWord;
    };

#endif /* ArgonInstruction_hpp */
