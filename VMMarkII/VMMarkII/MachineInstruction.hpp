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
#include "ArgonTypes.hpp"

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
        static char* bitStringFor(char* string,Pointer pointer);
        static char* bitStringFor(char* string,Word word);
    private:
        Word instructionWord;
        Word addressWord;
    };

#endif /* ArgonInstruction_hpp */
