//
//  CobaltMethod.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltMethod_hpp
#define CobaltMethod_hpp

#include <stdio.h>
#include "String.hpp"
#include "CobaltCodeBlock.hpp"
#include "CobaltArtefact.hpp"
#include "CobaltTraits.hpp"
#include "CobaltParameter.hpp"

class CobaltMethod:public CobaltArtefact
    {
    public:
        CobaltMethod(FILE* file);
        ~CobaltMethod();
    private:
        CobaltTraits* returnTraits;
        String* moduleName;
        String* methodName;
        CobaltParameter** parameters;
        long parameterCount;
        CobaltCodeBlock* code;
        bool isPrimitive;
        long primitiveNumber;
    };
    
#endif /* CobaltMethod_hpp */
