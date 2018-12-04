//
//  CobaltMethod.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltMethod.hpp"

CobaltMethod::CobaltMethod(FILE* file): CobaltArtefact(file)
    {
    returnTraits = new CobaltTraits(file);
    moduleName = readString(file);
    fread(&parameterCount,sizeof(long),1,file);
    parameters = new CobaltParameter*[parameterCount];
    for (long index=0;index<parameterCount;index++)
        {
        parameters[index] = new CobaltParameter(file);
        }
    code = new CobaltCodeBlock(file);
    long flag;
    fread(&flag,sizeof(long),1,file);
    isPrimitive = flag == 1;
    fread(&primitiveNumber,sizeof(long),1,file);
    }

CobaltMethod::~CobaltMethod()
    {
    delete code;
    for (long index=0;index<parameterCount;index++)
        {
        delete parameters[index];
        }
    delete [] parameters;
    delete returnTraits;
    delete moduleName;
    }
