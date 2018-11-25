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
#include "ArgonTypes.hpp"

class MemorySpace
    {
    public:
        MemorySpace(long capacity);
        ~MemorySpace();
        Pointer allocateBlockWithSizeInBytes(long sizeInBytes);
        Pointer allocateObject(int slotCount,int flags,Pointer traits);
        Pointer allocateString(char* string);
        Pointer allocateTraits(char* name,Pointer* parents);
        Pointer allocateMap(int capacity);
        Pointer allocateExtensionBlockCapacityInBytes(long capacity);
    private:
        Pointer basePointer;
        Pointer nextPointer;
        Pointer memoryTop;
    private:
        void initMemory(long capacity);
    };

#endif /* MemorySpace_hpp */
