//
//  CobaltRelocationTable.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltRelocationTable.hpp"

CobaltRelocationTable::CobaltRelocationTable(FILE* file) : CobaltArtefact(file)
    {
    long count;
    fread(&count,sizeof(long),1,file);
    entries = new CobaltRelocationEntry*[count];
    for (long index=0;index<count;index++)
        {
        CobaltRelocationEntry* entry = new CobaltRelocationEntry(file);
        entries[index] = entry;
        }
    entryCount = count;
    }

CobaltRelocationTable::~CobaltRelocationTable()
    {
    for (long index=0;index<entryCount;index++)
        {
        delete entries[index];
        }
    delete [] entries;
    }
