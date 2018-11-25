//
//  ArgonMemory.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "Memory.hpp"
#include "Object.hpp"
#include <string.h>
#include "ExtensionBlockPointerWrapper.hpp"
#include "StringPointerWrapper.hpp"

Memory* Memory::shared = new Memory(1024*1024*10);

Pointer Memory::allocateObject(int slotCount,int type,int flags,Pointer traits)
    {
    long totalBytes = (kObjectBaseSizeInWords + slotCount + 1) * kWordSize;
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(totalBytes);
    Object* object = (Object*)pointer;
    object->setSlotCount(slotCount);
    object->setFlags(flags);
    object->setGeneration(1);
    object->setIsForwarded(false);
    object->setType(type);
    object->traits = traits;
    return(pointer);
    }

Pointer Memory::allocateExtensionBlockWithCapacityInBytes(long capacity)
    {
    long totalBytes = (kExtensionBlockFixedSlotCount * kWordSize + capacity);
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(totalBytes);
    setWordAtIndexAtPointer(capacity,kExtensionBlockCountIndex,pointer);
    return(pointer);
    }

Memory::Memory(long capacity)
    {
    this->fromSpace = new MemorySpace(capacity);
    this->toSpace = new MemorySpace(capacity);
    this->finalSpace = new MemorySpace(capacity / 3);
    this->monitor = new Monitor();
    }

Pointer Memory::allocateString(char* string)
    {
    long totalBytes = kStringFixedSlotCount * kWordSize;
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(totalBytes);
    StringPointerWrapper wrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(kStringFixedSlotCount);
    wrapper.setType(kTypeString);
    wrapper.setIsForwarded(false);
    wrapper.setString(string);
    wrapper.extensionBlockPointer = zero;
    return(pointer);
    }

Pointer Memory::allocateMap(int capacity)
    {
    return(NULL);
    };

Pointer Memory::allocateTraits(char* name,Pointer* parents,long parentsCount)
    {
    return(NULL);
    };
