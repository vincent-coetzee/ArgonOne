//
//  CobaltCodeBlock.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltCodeBlock_hpp
#define CobaltCodeBlock_hpp

#include <stdio.h>
#include "MachineInstruction.hpp"
#include "CobaltArtefact.hpp"

class CobaltCodeBlock:public CobaltArtefact
    {
    public:
        CobaltCodeBlock(FILE* file);
    private:
        MachineInstruction* instructions;
        long instructionCount;
    };
#endif /* CobaltCodeBlock_hpp */
