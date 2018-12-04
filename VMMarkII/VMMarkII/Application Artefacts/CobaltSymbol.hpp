//
//  CobaltSymbol.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltSymbol_hpp
#define CobaltSymbol_hpp

#include <stdio.h>
#include "CobaltString.hpp"

class CobaltSymbol:public CobaltString
    {
    public:
        CobaltSymbol(FILE* file);
        ~CobaltSymbol();
    };
    
#endif /* CobaltSymbol_hpp */
