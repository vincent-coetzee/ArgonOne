//
//  CobaltGenericMethod.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltGenericMethod_hpp
#define CobaltGenericMethod_hpp

#include <stdio.h>
#include "String.hpp"
#include "CobaltArtefact.hpp"
#include "CobaltMethod.hpp"
#include "CobaltTraits.hpp"

class CobaltGenericMethod:public CobaltArtefact
    {
    public:
        CobaltGenericMethod(FILE* file);
    private:
        bool allowsAnyArity;
        long parameterCount;
        long kind;
        CobaltTraits* returnTraits;
        String* methodName;
        CobaltMethod** instances;
        long instanceCount;
    };
#endif /* CobaltGenericMethod_hpp */
