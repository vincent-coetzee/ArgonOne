//
//  ArgonMemory.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonMemory_hpp
#define ArgonMemory_hpp

#include <stdio.h>
#include "ArgonTypes.hpp"
#include "Monitor.hpp"
#include "MemorySpace.hpp"

class Memory
    {
    public:
        Memory(long capacity);
        ~Memory();
        Pointer allocateObject(int slotCount,int type,int flags,Pointer traits);
        Pointer allocateString(char* string);
        Pointer allocateExtensionBlockWithCapacityInBytes(long capacity);
        Pointer allocateMap(int capacity);
        Pointer allocateTraits(char* name,Pointer* parents,long parentsCount);
        Pointer allocateBlock(int capacity);
    public:
        static Memory* shared;
    private:
        MemorySpace* fromSpace;
        MemorySpace* toSpace;
        MemorySpace* finalSpace;
        Monitor* monitor;
    private:
        void initBaseTraits();
    };
    
#endif /* ArgonMemory_hpp */
