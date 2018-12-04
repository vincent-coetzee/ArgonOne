//
//  CobaltString.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltString.hpp"

CobaltString::CobaltString(FILE* file) : CobaltArtefact(file)
    {
    string = readString(file);
    }

CobaltString::~CobaltString()
    {
    }
