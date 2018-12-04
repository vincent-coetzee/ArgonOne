//
//  CobaltParameter.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltParameter.hpp"

CobaltParameter::CobaltParameter(FILE* file)
    {
    traits = new CobaltTraits(file);
    fread(&offsetFromBP,sizeof(long),1,file);
    }
