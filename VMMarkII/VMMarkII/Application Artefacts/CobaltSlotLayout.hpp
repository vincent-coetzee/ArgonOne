//
//  CobaltSlotLayout.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltSlotLayout_hpp
#define CobaltSlotLayout_hpp

#include <stdio.h>
#include "String.hpp"

class CobaltTraits;

class CobaltSlotLayout
    {
    public:
        CobaltSlotLayout(FILE* file);
    private:
        String* name;
        long offsetInInstance;
        CobaltTraits* traits;
    };

#endif /* CobaltSlotLayout_hpp */
