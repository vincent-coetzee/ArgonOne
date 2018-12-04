//
//  CobaltTypeTemplate.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltTypeTemplate.hpp"
#include "CobaltTraits.hpp"

CobaltTypeTemplate::CobaltTypeTemplate(FILE* file): CobaltArtefact(file)
    {
    name = readString(file);
    traits = new CobaltTraits(file);
    definingTraits = readString(file);
    }

CobaltTypeTemplate::~CobaltTypeTemplate()
    {
    delete name;
    delete traits;
    delete definingTraits;
    }

