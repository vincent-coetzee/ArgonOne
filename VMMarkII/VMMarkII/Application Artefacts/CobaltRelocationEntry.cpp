//
//  CobaltRelocationEntry.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltRelocationEntry.hpp"
#include "CobaltGenericMethod.hpp"
#include "CobaltTraits.hpp"
#include "CobaltClosure.hpp"
#include "CobaltString.hpp"
#include "CobaltSymbol.hpp"
#include "CobaltGlobal.hpp"
#include "CobaltHandler.hpp"

CobaltRelocationEntry::CobaltRelocationEntry(FILE* file)
    {
    fread(&itemKind,sizeof(long),1,file);
    switch(itemKind)
        {
        case(kGenericMethodKind):
            item = new CobaltGenericMethod(file);
        case(kTraitsKind):
            item = new CobaltTraits(file);
        case(kClosureKind):
            item = new CobaltClosure(file);
        case(kStringKind):
            item = new CobaltString(file);
        case(kSymbolKind):
            item = new CobaltSymbol(file);
        case(kGlobalKind):
            item = new CobaltGlobal(file);
        case(kNoneKind):
            break;
        case(kIntegerKind):
            break;
        case(kFloatKind):
            break;
        case(kBooleanKind):
            break;
        case(kTreeKind):
            break;
        case(kHandlerKind):
            item = new CobaltHandler(file);
        case(kMethodKind):
            item = new CobaltMethod(file);
        }
    }

CobaltRelocationEntry::~CobaltRelocationEntry()
    {
    }
