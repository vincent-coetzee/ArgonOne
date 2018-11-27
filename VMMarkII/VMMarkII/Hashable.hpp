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
        long virtual hashValue();
        bool virtual operator ==(Hashable const &hashable);
    };
    
#endif /* Hashable_hpp */
