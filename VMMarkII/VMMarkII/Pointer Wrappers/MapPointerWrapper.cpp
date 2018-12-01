//
//  MapPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "MapPointerWrapper.hpp"
#include "CobaltPointers.hpp"
#include "ObjectMemory.hpp"
#include <stdlib.h>

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

AssociationVectorPointerWrapper MapPointerWrapper::growAssociationVectorForHashbucket(long hashbucket,Pointer oldVectorPointer,long oldCapacity)
    {
    long newCapacity = oldCapacity * kMapAssociationVectorGrowthFactor;
    Pointer newVector = ObjectMemory::shared->allocateAssociationVectorOfSizeInWords(newCapacity);
    setPointerAtIndexAtPointer(newVector,kMapFixedSlotCount + hashbucket,this->actualPointer);
    AssociationVectorPointerWrapper newWrapper = AssociationVectorPointerWrapper(newVector);
    newWrapper.copyContentsOf(oldVectorPointer);
    return(newWrapper);
    }

Pointer MapPointerWrapper::createAssociationVectorForHashbucket(long hashbucket)
    {
    Pointer associationsPointer = ObjectMemory::shared->allocateAssociationVectorOfSizeInWords(kMapInitialAssociationVectorSlotCount);
    setPointerAtIndexAtPointer(associationsPointer,kMapFixedSlotCount + hashbucket,this->actualPointer);
    return(associationsPointer);
    }

void MapPointerWrapper::addWordForKey(Word word,Hashable* key)
    {
    long hashValue = clampedWord56(key->hashValue());
    long hashbucket = abs(hashValue) % kMapNumberOfHashbuckets;
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    if (associationsPointer == NULL)
        {
        associationsPointer = this->createAssociationVectorForHashbucket(hashbucket);
        }
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    if (wrapper.count() + 1 >= wrapper.capacity())
        {
        wrapper = this->growAssociationVectorForHashbucket(hashbucket,untaggedPointer(associationsPointer),wrapper.capacity());
        }
    wrapper.addWordAssociation(hashValue, word);
    this->setCount(this->count()+1);
    }

Word MapPointerWrapper::wordForKey(Hashable* key)
    {
    long hashValue = clampedWord56(key->hashValue());
    long hashbucket = abs(hashValue) % kMapNumberOfHashbuckets;
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    Word result = wrapper.wordAtHash(hashValue);
    return(result);
    }

void MapPointerWrapper::addPointerForKey(Pointer pointer,Hashable* key)
    {
    long hashValue = clampedWord56(key->hashValue());
    long hashbucket = abs(hashValue) % kMapNumberOfHashbuckets;
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    if (associationsPointer == NULL)
        {
        associationsPointer = this->createAssociationVectorForHashbucket(hashbucket);
        }
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    if (wrapper.count() + 1 >= wrapper.capacity())
        {
        wrapper = this->growAssociationVectorForHashbucket(hashbucket,untaggedPointer(associationsPointer),wrapper.capacity());
        }
    wrapper.addAssociation(hashValue, pointer);
    this->setCount(this->count()+1);
    }

Pointer MapPointerWrapper::pointerForKey(Hashable* key)
    {
    long hashValue = clampedWord56(key->hashValue());
    long hashbucket = abs(hashValue) % kMapNumberOfHashbuckets;
    Pointer associationsPointer = pointerAtIndexAtPointer(kMapFixedSlotCount+hashbucket,this->actualPointer);
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(associationsPointer);
    Pointer result = wrapper.pointerAtHash(hashValue);
    return(result);
    }
