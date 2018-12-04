//
//  CobaltHandler.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltHandler_hpp
#define CobaltHandler_hpp

#include <stdio.h>
#include "CobaltCodeBlock.hpp"
#include "CobaltArtefact.hpp"

class CobaltHandler:public CobaltArtefact
    {
    public:
        CobaltHandler(FILE* file);
    };
#endif /* CobaltHandler_hpp */
