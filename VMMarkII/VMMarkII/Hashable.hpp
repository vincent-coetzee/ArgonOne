//
//  Hashable.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef Hashable_hpp
#define Hashable_hpp

#include <stdio.h>


class Hashable
    {
    public:
        virtual long hashValue() = 0;
    };
    
#endif /* Hashable_hpp */
