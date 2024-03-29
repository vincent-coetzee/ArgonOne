//
//  ExtensionBlockPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "ExtensionBlockPointerWrapper.hpp"
#include "CobaltPointers.hpp"

ExtensionBlockPointerWrapper::ExtensionBlockPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    }

long ExtensionBlockPointerWrapper::count()
    {
    return((long)wordAtIndexAtPointer(kExtensionBlockCountIndex,this->actualPointer));
    }

void ExtensionBlockPointerWrapper::setCount(long count)
    {
    setWordAtIndexAtPointer((Word)count,kExtensionBlockCountIndex,this->actualPointer);
    }

long ExtensionBlockPointerWrapper::capacity()
    {
    return((long)wordAtIndexAtPointer(kExtensionBlockCapacityIndex,this->actualPointer));
    }

void ExtensionBlockPointerWrapper::setCapacity(long capacity)
    {
    setWordAtIndexAtPointer((Word)capacity,kExtensionBlockCapacityIndex,this->actualPointer);
    }

Pointer ExtensionBlockPointerWrapper::bytesPointer() const
    {
    WordPointer newPointer = (((WordPointer)this->actualPointer) + kExtensionBlockBytesIndex);
    return((Pointer)newPointer);
    }
