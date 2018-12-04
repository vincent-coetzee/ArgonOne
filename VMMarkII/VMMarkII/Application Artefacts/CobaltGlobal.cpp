//
//  CobaltGlobal.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltGlobal.hpp"

CobaltGlobal::CobaltGlobal(FILE* file): CobaltArtefact(file)
    {
    traits = new CobaltTraits(file);
    }

CobaltGlobal::~CobaltGlobal()
    {
    delete traits;
    }
