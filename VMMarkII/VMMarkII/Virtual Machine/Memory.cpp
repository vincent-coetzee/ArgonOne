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
#include "VectorPointerWrapper.hpp"
#include "ArgonPointers.hpp"
#include "MapPointerWrapper.hpp"
#include "AssociationVectorPointerWrapper.hpp"

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
    return(taggedObjectPointer(pointer));
    }

Pointer Memory::allocateExtensionBlockWithCapacityInBytes(long capacity)
    {
    long totalBytes = (kExtensionBlockFixedSlotCount * kWordSize + capacity);
    long totalWords = (totalBytes / 8) + 1;
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(totalBytes);
    ObjectPointerWrapper wrapper = ObjectPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(totalWords);
    wrapper.setType(kTypeExtensionBlock);
    wrapper.setIsForwarded(false);
    setWordAtIndexAtPointer(capacity/kWordSize,kExtensionBlockCapacityIndex,pointer);
    setWordAtIndexAtPointer(0,kExtensionBlockCountIndex,pointer);
    return(taggedExtensionBlockPointer(pointer));
    }

Memory::Memory(long capacity)
    {
    this->fromSpace = new MemorySpace(capacity);
    this->toSpace = new MemorySpace(capacity);
    this->finalSpace = new MemorySpace(capacity / 3);
    this->monitor = new Monitor();
    }

Pointer Memory::allocateBlock(int capacity)
    {
    return(toSpace->allocateBlockWithSizeInBytes(capacity));
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
    return(taggedStringPointer(pointer));
    }

Pointer Memory::allocateVectorWithCapacityInWords(long capacityInWords)
    {
    long storageCapacity = capacityInWords * 3 / 2;
    long storageCapacityInBytes = storageCapacity*kWordSize;
    long totalBytes = kVectorFixedSlotCount * kWordSize;
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(totalBytes);
    VectorPointerWrapper wrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(storageCapacity);
    wrapper.setType(kTypeString);
    wrapper.setIsForwarded(false);
    wrapper.setCount(0);
    wrapper.setCapacity(storageCapacity);
    wrapper.setExtensionsBlockPointer(this->allocateExtensionBlockWithCapacityInBytes(storageCapacityInBytes));
    return(taggedVectorPointer(pointer));
    }
    
Pointer Memory::allocateMap()
    {
    long storageCapacity = kMapFixedSlotCount + kMapHashBucketPrime;
    long storageInBytes = storageCapacity * kWordSize;
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(storageInBytes);
    MapPointerWrapper wrapper = MapPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(storageCapacity);
    wrapper.setType(kTypeMap);
    wrapper.setIsForwarded(false);
    wrapper.setCount(0);
    wrapper.setCapacity(storageCapacity);
    wrapper.setHashbucketCount(kMapHashBucketPrime);
    return(taggedMapPointer(pointer));
    }

Pointer Memory::allocateAssociationVectorOfSizeInWords(long wordCount)
    {
    long storageCapacity = kAssociationVectorFixedSlotCount + (wordCount*2);
    long storageInBytes = storageCapacity * kWordSize;
    Pointer pointer = toSpace->allocateBlockWithSizeInBytes(storageInBytes);
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(storageCapacity);
    wrapper.setType(kTypeAssociationVector);
    wrapper.setIsForwarded(false);
    wrapper.setCount(0);
    wrapper.setCapacity(storageCapacity);
    return(taggedObjectPointer(pointer));
    }

Pointer Memory::allocateTraits(char* name,Pointer* parents,long parentsCount)
    {
    return(NULL);
    };
