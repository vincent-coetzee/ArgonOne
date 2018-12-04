//
//  CobaltString.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltString_hpp
#define CobaltString_hpp

#include <stdio.h>
#include "String.hpp"
#include "CobaltArtefact.hpp"

class CobaltString:public CobaltArtefact
    {
    public:
        CobaltString(FILE* file);
        ~CobaltString();
    private:
        String* string;
    };
#endif /* CobaltString_hpp */
