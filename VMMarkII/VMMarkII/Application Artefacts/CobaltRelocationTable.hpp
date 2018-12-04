//
//  CobaltRelocationTable.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltRelocationTable_hpp
#define CobaltRelocationTable_hpp

#include <stdio.h>
#include "CobaltArtefact.hpp"
#include "String.hpp"
#include "CobaltRelocationEntry.hpp"

class CobaltRelocationTable:CobaltArtefact
    {
    public:
        CobaltRelocationTable(FILE* file);
        ~CobaltRelocationTable();
    private:
        long entryCount;
        CobaltRelocationEntry** entries;
    };

#endif /* CobaltRelocationTable_hpp */
