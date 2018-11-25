//
//  ObjectPointer.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "ObjectPointerWrapper.hpp"

ObjectPointerWrapper::ObjectPointerWrapper(Pointer pointer)
    {
    this->actualPointer = untaggedPointer(pointer);
    this->objectPointer = (Object*)untaggedPointer(pointer);
    }

long ObjectPointerWrapper::slotCount()
    {
    return(objectPointer->slotCount());
    }

void ObjectPointerWrapper::setSlotCount(long count)
    {
    objectPointer->setSlotCount(count);
    }

bool ObjectPointerWrapper::isForwarded()
    {
    return(objectPointer->isForwarded());
    }

void ObjectPointerWrapper::setIsForwarded(bool flag)
    {
    objectPointer->setIsForwarded(flag);
    }

long ObjectPointerWrapper::type()
    {
    return(objectPointer->type());
    }

void ObjectPointerWrapper::setType(long type)
    {
    objectPointer->setType(type);
    }

long ObjectPointerWrapper::flags()
    {
    return(objectPointer->flags());
    }

void ObjectPointerWrapper::setFlags(long flags)
    {
    objectPointer->setFlags(flags);
    }

long ObjectPointerWrapper::generation()
    {
    return(objectPointer->generation());
    }

void ObjectPointerWrapper::setGeneration(long count)
    {
    objectPointer->setGeneration(count);
    }

Pointer ObjectPointerWrapper::traits()
    {
    return(objectPointer->traits);
    }

Pointer ObjectPointerWrapper::mutex()
    {
    return(objectPointer->mutex);
    }

Pointer ObjectPointerWrapper::condition()
    {
    return(objectPointer->condition);
    }

Word ObjectPointerWrapper::wordAtIndex(long index)
    {
    return(wordAtIndexAtPointer(index,this->actualPointer));
    };

Pointer ObjectPointerWrapper::pointerAtIndex(long index)
    {
    return(pointerAtIndexAtPointer(index,this->actualPointer));
    }

void ObjectPointerWrapper::setWordAtIndex(Word word,long index)
    {
    setWordAtIndexAtPointer(word,index,this->actualPointer);
    }

void ObjectPointerWrapper::setPointerAtIndex(Pointer pointer,long index)
    {
    setPointerAtIndexAtPointer(pointer,index,this->actualPointer);
    }
