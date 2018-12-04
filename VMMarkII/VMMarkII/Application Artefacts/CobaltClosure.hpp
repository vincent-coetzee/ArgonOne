//
//  CobaltClosure.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltClosure_hpp
#define CobaltClosure_hpp

#include <stdio.h>
#include "CobaltCodeBlock.hpp"
#include "CobaltArtefact.hpp"

class CobaltClosure:public CobaltArtefact
    {
    public:
        CobaltClosure(FILE* file);
        ~CobaltClosure();
    private:
        CobaltCodeBlock* code;
    };
    
#endif /* CobaltClosure_hpp */
