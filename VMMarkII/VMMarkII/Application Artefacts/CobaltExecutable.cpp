//
//  ExecutableReader.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltExecutable.hpp"
#include <string.h>
#include "String.hpp"
#include <iostream>
#include "CobaltTypes.hpp"
#include "CobaltRelocationEntry.hpp"
#include "CobaltArtefact.hpp"

CobaltExecutable::CobaltExecutable(char const* path)
    {
    long length = strlen(path) + 1;
    this->path = new char[length];
    strcpy(this->path,path);
    }

CobaltExecutable::~CobaltExecutable()
    {
    delete [] path;
    }

void CobaltExecutable::open()
    {
    file = fopen(path,"r+t");
    }

void CobaltExecutable::readObjects()
    {
    fseek(file,sizeof(long),SEEK_SET);
    long marker;
    do
        {
        fread(&marker,sizeof(long),1,file);
        if (marker == kMarkerObject)
            {
            this->readObject();
            }
        else
            {
            this->readReference();
            }
        }
    while (marker != kMarkerObjectsEnd);
    }


    
void CobaltExecutable::readObject()
    {
    String* className;
    
    className = CobaltArtefact::readString(file);
    if (*className == String("ArgonRelocationTable"))
        {
        long count;
        fread(&count,sizeof(long),1,file);
        for (long index=0;index<count;index++)
            {
            CobaltRelocationEntry* entry = new CobaltRelocationEntry(file);
            }
        }
    }

void CobaltExecutable::readReference()
    {
    
    }

void CobaltExecutable::readObjectTable()
    {
    long position;
    fread(&position,sizeof(long),1,file);
    fseek(file,position+sizeof(long),SEEK_SET);
    fread(&sizeOfTable,sizeof(long),1,file);
    objectTable = new ObjectEntry*[sizeOfTable];
    for (long index=0;index<sizeOfTable;index++)
        {
        ObjectEntry* entry = new ObjectEntry();
        long longValue;
        fread(&longValue,sizeof(long),1,file);
        entry->name = CobaltArtefact::readString(file);
        entry->hashValue = longValue;
        objectTable[index] = entry;
        }
    for (long index=0;index<sizeOfTable;index++)
        {
        ObjectEntry* entry = objectTable[index];
        std::cout << entry->name->characters() << " -> " << entry->hashValue << "\n";
        }
    }
