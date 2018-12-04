//
//  CobaltParameter.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltParameter_hpp
#define CobaltParameter_hpp

#include <stdio.h>
#include "String.hpp"
#include "CobaltTraits.hpp"

class CobaltParameter
    {
    public:
        CobaltParameter(FILE* file);
    private:
        CobaltTraits* traits;
        long offsetFromBP;
    };
#endif /* CobaltParameter_hpp */
