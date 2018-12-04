//
//  CobaltArtefact.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "CobaltArtefact.hpp"
#include "CobaltTypes.hpp"

CobaltArtefact::CobaltArtefact(FILE* file)
    {
    long marker;
    fread(&marker,sizeof(long),1,file);
    if (marker == kMarkerObject)
        {
        name = readString(file);
        fullName = readString(file);
        fread(&identifier,sizeof(long),1,file);
        }
    else if (marker == kMarkerReference)
        {
        
        }
    }

String* CobaltArtefact::readString(FILE* file)
    {
    long stringLength;
    fread(&stringLength,sizeof(long),1,file);
    char* string = new char[stringLength+1];
    fread(string,1,stringLength,file);
    string[stringLength] = 0;
    return(new String(string));
    }
