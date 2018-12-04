//
//  CobaltArtefact.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef CobaltArtefact_hpp
#define CobaltArtefact_hpp

#include <stdio.h>
#include "String.hpp"

class CobaltArtefact
    {
    public:
        CobaltArtefact(FILE* file);
        static String* readString(FILE* file);
    protected:
        String* name;
        String* fullName;
        long identifier;
    };
    
#endif /* CobaltArtefact_hpp */
