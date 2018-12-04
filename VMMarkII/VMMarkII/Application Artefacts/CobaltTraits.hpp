//
//  CobaltTraits.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltTraits_hpp
#define CobaltTraits_hpp

#include <stdio.h>
#include "String.hpp"
#include "CobaltArtefact.hpp"
#include "CobaltSlotLayout.hpp"
#include "CobaltTypeTemplate.hpp"

class CobaltTraits:public CobaltArtefact
    {
    public:
        CobaltTraits(FILE* file);
    private:
        long slotLayoutCount;
        CobaltSlotLayout** slotLayouts;
        CobaltTraits** parents;
        long parentCount;
        long typeTemplateCount;
        CobaltTypeTemplate** typeTemplates;
        long kind;
    };

#endif /* CobaltTraits_hpp */
