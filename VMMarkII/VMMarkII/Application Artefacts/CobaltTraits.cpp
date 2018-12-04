//
//  CobaltTraits.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltTraits.hpp"
#include "CobaltSlotLayout.hpp"

CobaltTraits::CobaltTraits(FILE* file) : CobaltArtefact(file)
    {
    fread(&slotLayoutCount,sizeof(long),1,file);
    slotLayouts = new CobaltSlotLayout*[slotLayoutCount];
    for (long index=0;index<slotLayoutCount;index++)
        {
        slotLayouts[index] = new CobaltSlotLayout(file);
        }
    fread(&parentCount,sizeof(long),1,file);
    parents = new CobaltTraits*[parentCount];
    for (long index=0;index<parentCount;index++)
        {
        parents[index] = new CobaltTraits(file);
        }
    fread(&typeTemplateCount,sizeof(long),1,file);
    typeTemplates = new CobaltTypeTemplate*[typeTemplateCount];
    for (long index=0;index<typeTemplateCount;index++)
        {
        typeTemplates[index] = new CobaltTypeTemplate(file);
        }
    fread(&kind,sizeof(long),1,file);
    }
