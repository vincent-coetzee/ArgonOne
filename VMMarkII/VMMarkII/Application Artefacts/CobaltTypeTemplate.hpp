//
//  CobaltTypeTemplate.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltTypeTemplate_hpp
#define CobaltTypeTemplate_hpp

#include <stdio.h>
#include "String.hpp"
#include "CobaltArtefact.hpp"

class CobaltTraits;

class CobaltTypeTemplate:public CobaltArtefact
    {
    public:
        CobaltTypeTemplate(FILE* file);
        ~CobaltTypeTemplate();
    private:
        String* name;
        CobaltTraits* traits;
        String* definingTraits;
    };

#endif /* CobaltTypeTemplate_hpp */
