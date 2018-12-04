//
//  CobaltGlobal.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltGlobal_hpp
#define CobaltGlobal_hpp

#include <stdio.h>
#include "CobaltArtefact.hpp"
#include "CobaltTraits.hpp"

class CobaltGlobal:public CobaltArtefact
    {
    public:
        CobaltGlobal(FILE* file);
        ~CobaltGlobal();
    private:
        CobaltTraits* traits;
    };
#endif /* CobaltGlobal_hpp */
