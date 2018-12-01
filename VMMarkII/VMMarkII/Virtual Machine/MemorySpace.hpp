//
//  MemorySpace.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef MemorySpace_hpp
#define MemorySpace_hpp

#include <stdio.h>
#include "CobaltTypes.hpp"

#define spaceContainsPointer(s,p) (s->basePointer <= p && s->memoryTop > p)

class MemorySpace
    {
    public:
        MemorySpace(long capacity);
        ~MemorySpace();
        Pointer allocateBlockWithSizeInWords(long sizeInWords);
        friend class ObjectMemory;
    private:
        Pointer basePointer;
        Pointer nextPointer;
        Pointer memoryTop;
    private:
        void initMemory(long capacity);
    };

#endif /* MemorySpace_hpp */
