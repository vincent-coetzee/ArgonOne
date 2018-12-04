//
//  CobaltClosure.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltClosure.hpp"

CobaltClosure::CobaltClosure(FILE* file) : CobaltArtefact(file)
    {
    code = new CobaltCodeBlock(file);
    }

CobaltClosure::~CobaltClosure()
    {
    delete code;
    }
