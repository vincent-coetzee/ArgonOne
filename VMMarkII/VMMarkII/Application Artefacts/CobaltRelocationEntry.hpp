//
//  CobaltRelocationEntry.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltRelocationEntry_hpp
#define CobaltRelocationEntry_hpp

#include <stdio.h>
#include "CobaltArtefact.hpp"
#include "String.hpp"



class CobaltRelocationEntry
    {
    public:
        CobaltRelocationEntry(FILE* file);
        ~CobaltRelocationEntry();
    private:
        CobaltArtefact* item;
        long itemKind;
        String** labels;
        long labelCount;
    };

#endif /* CobaltRelocationEntry_hpp */
