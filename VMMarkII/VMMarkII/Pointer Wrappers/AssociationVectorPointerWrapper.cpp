//
//  AssociationVectorPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "AssociationVectorPointerWrapper.hpp"

AssociationVectorPointerWrapper::AssociationVectorPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    }

long AssociationVectorPointerWrapper::copyContentsOf(Pointer pointer)
    {
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(pointer);
    this->setCount(wrapper.count());
    for (long index = kAssociationVectorFixedSlotCount;index< kAssociationVectorFixedSlotCount + wrapper.count()*2;index+=2)
        {
        setWordAtIndexAtPointer(wordAtIndexAtPointer(index,wrapper.actualPointer),index,this->actualPointer);
        setWordAtIndexAtPointer(wordAtIndexAtPointer(index+1,wrapper.actualPointer),index+1,this->actualPointer);
        }
    return(this->count());
    }

long AssociationVectorPointerWrapper::count()
    {
    return(wordAtIndexAtPointer(kAssociationVectorCountIndex,this->actualPointer));
    };

void AssociationVectorPointerWrapper::setCount(long count)
    {
    setWordAtIndexAtPointer(count,kAssociationVectorCountIndex,this->actualPointer);
    };

long AssociationVectorPointerWrapper::capacity()
    {
    return(wordAtIndexAtPointer(kAssociationVectorCapacityIndex,this->actualPointer));
    };

void AssociationVectorPointerWrapper::setCapacity(long count)
    {
    setWordAtIndexAtPointer(count,kAssociationVectorCapacityIndex,this->actualPointer);
    };

void AssociationVectorPointerWrapper::addAssociation(long hash,Pointer pointer)
    {
    long index = this->count() * 2 + kAssociationVectorFixedSlotCount;
    setWordAtIndexAtPointer(((Word)hash),index++,this->actualPointer);
    setPointerAtIndexAtPointer(pointer,index,this->actualPointer);
    this->setCount(this->count() + 1);
    };

void AssociationVectorPointerWrapper::addWordAssociation(long hash,Word word)
    {
    long index = this->count() * 2 + kAssociationVectorFixedSlotCount;
    setWordAtIndexAtPointer(((Word)hash),index++,this->actualPointer);
    setWordAtIndexAtPointer(word,index,this->actualPointer);
    this->setCount(this->count() + 1);
    }

Pointer AssociationVectorPointerWrapper::pointerAtHash(long hash)
    {
    long count = this->count() * 2 + kAssociationVectorFixedSlotCount;
    for (long index = kAssociationVectorFixedSlotCount;index<count;index+=2)
        {
        if (wordAtIndexAtPointer(index,this->actualPointer) == ((Word)hash))
            {
            return(pointerAtIndexAtPointer(index+1,this->actualPointer));
            }
        }
    return(NULL);
    };

Word AssociationVectorPointerWrapper::wordAtHash(long hash)
    {
    long count = this->count() * 2 + kAssociationVectorFixedSlotCount;
    for (long index = kAssociationVectorFixedSlotCount;index<count;index+=2)
        {
        if (wordAtIndexAtPointer(index,this->actualPointer) == ((Word)hash))
            {
            return(wordAtIndexAtPointer(index+1,this->actualPointer));
            }
        }
    return(0);
    };

void AssociationVectorPointerWrapper::deleteAtHash(long hash)
    {
    };
