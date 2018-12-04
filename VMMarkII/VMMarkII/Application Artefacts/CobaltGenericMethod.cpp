//
//  CobaltGenericMethod.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltGenericMethod.hpp"

CobaltGenericMethod::CobaltGenericMethod(FILE* file) : CobaltArtefact(file)
    {
    fread(&kind,sizeof(long),1,file);
    fread(&instanceCount,sizeof(long),1,file);
    instances = new CobaltMethod*[instanceCount];
    for (long index=0;index<instanceCount;index++)
        {
        CobaltMethod* method = new CobaltMethod(file);
        instances[index] = method;
        }
    returnTraits = new CobaltTraits(file);
    fread(&parameterCount,sizeof(long),1,file);
    long allowsArity;
    fread(&allowsArity,sizeof(long),1,file);
    allowsAnyArity = allowsArity == 1;
    };
