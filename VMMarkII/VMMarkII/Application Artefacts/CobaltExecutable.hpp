//
//  ExecutableReader.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ExecutableReader_hpp
#define ExecutableReader_hpp

#include <stdio.h>
#include "String.hpp"

struct ObjectEntry
    {
    public:
        String* name;
        long hashValue;
    };

class CobaltExecutable
    {
    public:
        CobaltExecutable(char const* path);
        ~CobaltExecutable();
    public:
        void open();
        void readObjectTable();
        void readObjects();
    private:
        void readObject();
        void readReference();
        void readGenericMethodKind();
        void readBooleanKind();
        void readIntegerKind();
        void readTreeKind();
        void readMethodKind();
        void readStringKind();
        void readSymbolKind();
        void readFloatKind();
        void readTraitsKind();
        void readHandlerKind();
        void readCodeBlockKind();
    private:
        char* path;
        FILE* file;
        long sizeOfTable;
        ObjectEntry** objectTable;
    };
#endif /* ExecutableReader_hpp */
