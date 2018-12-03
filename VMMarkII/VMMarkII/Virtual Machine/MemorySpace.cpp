//
//  MemorySpace.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "MemorySpace.hpp"
#include <stdlib.h>
#include "MachineInstruction.hpp"
#include <string.h>

Pointer addIntToPointer(unsigned long value,Pointer pointer)
    {
    return((void*)(((char*)pointer)+value));
    }

MemorySpace::MemorySpace(long capacity)
    {
    initMemory(capacity);
    this->capacity = capacity;
    }

void MemorySpace::initMemory(long capacity)
    {
    basePointer = malloc(capacity);
    char string[200];
    nextPointer = basePointer;
     printf("Next Pointer : %s\n",string);
    memoryTop = addIntToPointer(-kWordSize,addIntToPointer(capacity,basePointer));
     printf("Top Pointer  : %s\n",string);
    }

void MemorySpace::reset()
    {
    nextPointer = basePointer;
    memoryTop = addIntToPointer(-kWordSize,addIntToPointer(capacity,basePointer));
    }

MemorySpace::~MemorySpace()
    {
    free((char*)basePointer);
    }

Pointer MemorySpace::allocateBlockWithSizeInWords(long sizeInWords)
    {
    Pointer pointer = nextPointer;
    long bytesSize = sizeInWords * kWordSize;
    if (addIntToPointer(bytesSize,nextPointer) >= memoryTop)
        {
        throw(RuntimeException::outOfMemory);
        }
    memset(pointer,(int)bytesSize,0);
    nextPointer = addIntToPointer(bytesSize,nextPointer);
    return(pointer);
    }


