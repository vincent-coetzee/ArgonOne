//
//  StringPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "StringPointerWrapper.hpp"
#include "ExtensionBlockPointerWrapper.hpp"
#include "string.h"
#include "ArgonTypes.hpp"

StringPointerWrapper::StringPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    }

long StringPointerWrapper::count()
    {
    return(ExtensionBlockPointerWrapper(pointerAtIndex(kStringExtensionBlockIndex)).count());
    }

char* StringPointerWrapper::string()
    {
    return((char*)ExtensionBlockPointerWrapper(pointerAtIndex(kStringExtensionBlockIndex)).bytesPointer());
    }

void StringPointerWrapper::setExtensionBlockPointer(Pointer value)
    {
    setPointerAtIndexAtPointer(value,kStringExtensionBlockIndex,this->actualPointer);
    }

Pointer StringPointerWrapper::extensionBlockPointer()
    {
    return(pointerAtIndexAtPointer(kStringExtensionBlockIndex,this->actualPointer));
    }
    
void StringPointerWrapper::setString(char* string)
    {
    Pointer extensionPointer = pointerAtIndex(kStringExtensionBlockIndex);
    ExtensionBlockPointerWrapper* wrapper;
    long bytesNeeded = strlen(string) + 1;
    setWordAtIndex(bytesNeeded-1,kStringCountIndex);
    if (extensionPointer != NULL)
        {
        wrapper = new ExtensionBlockPointerWrapper(extensionPointer);
        if (wrapper->capacity() > bytesNeeded)
            {
            strcpy((char*)wrapper->bytesPointer(),string);
            wrapper->setCount(bytesNeeded-1);
            delete wrapper;
            return;
            }
        }
    long extraInBlock = bytesNeeded / 4;
    extraInBlock = extraInBlock < 20 ? 20 : extraInBlock;
    Word totalBytes = bytesNeeded + extraInBlock;
    extensionPointer = Memory::shared->allocateExtensionBlockWithCapacityInBytes(bytesNeeded);
    wrapper = new ExtensionBlockPointerWrapper(extensionPointer);
    wrapper->setCount(bytesNeeded);
    wrapper->setCapacity(totalBytes);
    strcpy((char*)wrapper->bytesPointer(),string);
    setPointerAtIndex(extensionPointer,kStringExtensionBlockIndex);
    delete wrapper;
    }
