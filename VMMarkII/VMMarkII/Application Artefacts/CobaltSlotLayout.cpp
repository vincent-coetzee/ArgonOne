//
//  CobaltSlotLayout.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltSlotLayout.hpp"
#include "CobaltTraits.hpp"

CobaltSlotLayout::CobaltSlotLayout(FILE* file)
    {
    name = CobaltArtefact::readString(file);
    }
