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
    }

void MemorySpace::initMemory(long capacity)
    {
    basePointer = malloc(capacity);
    char string[200];
    MachineInstruction::bitStringFor(string, basePointer);
    printf("Base Pointer : %s\n",string);
    nextPointer = basePointer;
    MachineInstruction::bitStringFor(string, nextPointer);
     printf("Next Pointer : %s\n",string);
    memoryTop = addIntToPointer(-kWordSize,addIntToPointer(capacity,basePointer));
    MachineInstruction::bitStringFor(string, memoryTop);
     printf("Top Pointer  : %s\n",string);
    }

MemorySpace::~MemorySpace()
    {
    delete ((char*)basePointer);
    }

Pointer MemorySpace::allocateBlockWithSizeInBytes(long sizeInBytes)
    {
    Pointer pointer = nextPointer;
    long bytesSize = ((sizeInBytes / kWordSize) + 1) * kWordSize;
    if (addIntToPointer(bytesSize,nextPointer) >= memoryTop)
        {
        throw(RuntimeException::outOfMemory);
        }
    memset(pointer,(int)sizeInBytes,0);
    nextPointer = addIntToPointer(bytesSize,nextPointer);
    return(pointer);
    }


