//
//  ArgonObject.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonObject_hpp
#define ArgonObject_hpp

#include <stdio.h>
#include "ArgonTypes.hpp"

typedef struct _ArgonObject
    {
    public:
        Word header;
        Pointer traits;
        Pointer mutex;
        Pointer condition;
    public:
        _ArgonObject();
        ~_ArgonObject();
        bool isForwarded();
        void setIsForwarded(bool flag);
        long slotCount();
        void setSlotCount(long count);
        long generation();
        void setGeneration(long count);
        long type();
        void setType(long type);
        long flags();
        void setFlags(long flags);
    }
    Object;
    
#endif /* ArgonObject_hpp */
