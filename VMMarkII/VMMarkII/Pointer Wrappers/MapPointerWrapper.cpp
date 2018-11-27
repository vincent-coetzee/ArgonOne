//
//  MapPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "MapPointerWrapper.hpp"
#include "ArgonPointers.hpp"
#include "Memory.hpp"

MapPointerWrapper::MapPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    }
    
long MapPointerWrapper::count() const
    {
    return(wordAtIndexAtPointer(kMapCountIndex,this->actualPointer));
    }

void MapPointerWrapper::setCount(long count)
    {
    setWordAtIndexAtPointer(count,kMapCountIndex,this->actualPointer);
    }

long MapPointerWrapper::capacity()
    {
    return(wordAtIndexAtPointer(kMapCapacityIndex,this->actualPointer));
    }

void MapPointerWrapper::setCapacity(long count)
    {
    setWordAtIndexAtPointer(count,kMapCapacityIndex,this->actualPointer);
    }

long MapPointerWrapper::hashbucketCount()
    {
    return(wordAtIndexAtPointer(kMapHashbucketCountIndex,this->actualPointer));
    }

void MapPointerWrapper::setHashbucketCount(long count)
    {
    setWordAtIndexAtPointer(count,kMapHashbucketCountIndex,this->actualPointer);
    }

AssociationVectorPointerWrapper MapPointerWrapper::growAssociationVector(AssociationVectorPointerWrapper wrapper)
    {
    long newCapacity = wrapper.capacity() * 5 / 3;
    Pointer newVector = Memory::shared->allocateAssociationVectorOfSizeInWords(newCapacity);
    setPointerAtIndexAtPointer(newVector,kMapAssociationVectorIndex,this->actualPointer);
    AssociationVectorPointerWrapper newWrapper = AssociationVectorPointerWrapper(newVector);
    newWrapper.copyContentsOf(wrapper.actualPointer);
    return(newWrapper);
    }

Pointer MapPointerWrapper::createAssociationVector()
    {
    Pointer associationsPointer = Memory::shared->allocateAssociationVectorOfSizeInWords(kMapHashBucketLengthPrime);
    setPointerAtIndexAtPointer(associationsPointer,kMapAssociationVectorIndex,this->actualPointer);
    return(associationsPointer);
    }

void MapPointerWrapper::addWordForKey(Word word,Hashable key)
    {
    long hashValue = key.hashValue();
    long hashbucket = hashValue % wordAtIndexAtPointer(kMapHashbucketCountIndex,this->actualPointer);
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    if (associationsPointer == NULL)
        {
        associationsPointer = this->createAssociationVector();
        }
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    if (wrapper.count() + 1 >= wrapper.capacity())
        {
        wrapper = this->growAssociationVector(wrapper);
        }
    wrapper.addWordAssociation(hashValue, word);
    }

Word MapPointerWrapper::wordForKey(Hashable key)
    {
    long hashValue = key.hashValue();
    long hashbucket = hashValue % wordAtIndexAtPointer(kMapHashbucketCountIndex,this->actualPointer);
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    Word result = wrapper.wordAtHash(key.hashValue());
    return(result);
    }

void MapPointerWrapper::addPointerForKey(Pointer pointer,Hashable key)
    {
    long hashValue = key.hashValue();
    long hashbucket = hashValue % wordAtIndexAtPointer(kMapHashbucketCountIndex,this->actualPointer);
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    if (associationsPointer == NULL)
        {
        associationsPointer = this->createAssociationVector();
        }
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    if (wrapper.count() + 1 >= wrapper.capacity())
        {
        wrapper = this->growAssociationVector(wrapper);
        }
    wrapper.addAssociation(hashValue, pointer);
    }

Pointer MapPointerWrapper::pointerForKey(Hashable key)
    {
    long hashValue = key.hashValue();
    long hashbucket = hashValue % wordAtIndexAtPointer(kMapHashbucketCountIndex,this->actualPointer);
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    Pointer result = wrapper.pointerAtHash(key.hashValue());
    return(result);
    }
