//
//  VectorPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "VectorPointerWrapper.hpp"
#include "ObjectMemory.hpp"
#include <string.h>
#include "CobaltPointers.hpp"
#include "ExtensionBlockPointerWrapper.hpp"

VectorPointerWrapper::VectorPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    };

long VectorPointerWrapper::count()
    {
    return((long)wordAtIndex(kVectorCountIndex));
    };

void VectorPointerWrapper::setCount(long count)
    {
    setWordAtIndex((Word)count,kVectorCountIndex);
    };

long VectorPointerWrapper::capacity()
    {
    return((long)wordAtIndex(kVectorCapacityIndex));
    }

void VectorPointerWrapper::setCapacity(long capacity)
    {
    setWordAtIndex((Word)capacity,kVectorCapacityIndex);
    }

Pointer VectorPointerWrapper::extensionsBlockPointer()
    {
    return(pointerAtIndex(kVectorExtensionBlockIndex));
    }

void VectorPointerWrapper::setExtensionsBlockPointer(Pointer pointer)
    {
    setPointerAtIndex(pointer,kVectorExtensionBlockIndex);
    }

void VectorPointerWrapper::addWordElement(Word element)
    {
    Pointer blockPointer = pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer);
    Word count = wordAtIndexAtPointer(kExtensionBlockCountIndex,blockPointer);
    Word capacity = wordAtIndexAtPointer(kExtensionBlockCapacityIndex,blockPointer);
    if (count + 1 >= capacity)
        {
        this->growVector();
        blockPointer = (WordPointer)pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer);
        count = wordAtIndexAtPointer(kExtensionBlockCountIndex,blockPointer);
        capacity = wordAtIndexAtPointer(kExtensionBlockCapacityIndex,blockPointer);
        }
    setWordAtIndexAtPointer(element,kExtensionBlockBytesIndex + count,blockPointer);
    setWordAtIndexAtPointer(count+1,kExtensionBlockCountIndex,blockPointer);
    setWordAtIndexAtPointer(count+1,kVectorCountIndex,this->actualPointer);
    }

void VectorPointerWrapper::addPointerElement(Pointer element)
    {
    Pointer blockPointer = pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer);
    Word count = wordAtIndexAtPointer(kExtensionBlockCountIndex,blockPointer);
    Word capacity = wordAtIndexAtPointer(kExtensionBlockCapacityIndex,blockPointer);
    if (count + 1 >= capacity)
        {
        this->growVector();
        blockPointer = (WordPointer)pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer);
        count = wordAtIndexAtPointer(kExtensionBlockCountIndex,blockPointer);
        capacity = wordAtIndexAtPointer(kExtensionBlockCapacityIndex,blockPointer);
        }
    Pointer elementPointer = ((WordPointer)blockPointer) + (kExtensionBlockBytesIndex + count);
    setPointerAtPointer(element,elementPointer);
    setWordAtIndexAtPointer(count+1,kExtensionBlockCountIndex,blockPointer);
    setWordAtIndexAtPointer(count+1,kVectorCountIndex,this->actualPointer);
    };

Pointer VectorPointerWrapper::pointerElementAtIndex(long index)
    {
    WordPointer blockPointer = (WordPointer)pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer);
    blockPointer += kExtensionBlockBytesIndex + index;
    return(pointerAtPointer(blockPointer));
    };

Word VectorPointerWrapper::wordElementAtIndex(long index)
    {
    WordPointer blockPointer = (WordPointer)pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer);
    blockPointer += kExtensionBlockBytesIndex + index;
    return(wordAtPointer(blockPointer));
    };

void VectorPointerWrapper::growVector()
    {
    printf("Vector is growing\n");
    long preCount = this->count();
    Pointer blockPointer = untaggedPointer(pointerAtIndexAtPointer(kVectorExtensionBlockIndex,this->actualPointer));
    Word currentCapacity = wordAtIndexAtPointer(kExtensionBlockCapacityIndex,blockPointer);
    Word newCapacity = currentCapacity * 5 / 3;
    printf("Vector is growing to new size of %ld\n",(long)newCapacity);
    Pointer newBlockPointer = untaggedPointer(ObjectMemory::shared->allocateExtensionBlockWithCapacityInWords(newCapacity));
    setPointerAtIndexAtPointer(newBlockPointer,kVectorExtensionBlockIndex,this->actualPointer);
    WordPointer currentPointer = (WordPointer)blockPointer;
    WordPointer newPointer = (WordPointer)newBlockPointer;
    currentPointer++;
    newPointer++;
    Word currentSizeInBytes = (currentCapacity + kExtensionBlockFixedSlotCount - 1)*kWordSize;
    memcpy(newPointer,currentPointer,currentSizeInBytes);
    setWordAtIndexAtPointer(this->count(),kExtensionBlockCountIndex,newBlockPointer);
    setWordAtIndexAtPointer(newCapacity,kExtensionBlockCapacityIndex,newBlockPointer);
    long postCount = this->count();
    printf("Vector successfully grew, preCount = %ld, postCount = %ld\n",preCount,postCount);
    };
