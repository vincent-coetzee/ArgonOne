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
#include "CobaltTypes.hpp"
#include "CobaltPointers.hpp"

StringPointerWrapper::StringPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    }

long StringPointerWrapper::count()
    {
    return(ExtensionBlockPointerWrapper(pointerAtIndex(kStringExtensionBlockIndex)).count());
    }

char* StringPointerWrapper::string() const
    {
    return((char*)ExtensionBlockPointerWrapper(pointerAtIndex(kStringExtensionBlockIndex)).bytesPointer());
    }

void StringPointerWrapper::setExtensionBlockPointer(Pointer value)
    {
    setPointerAtIndexAtPointer(value,kStringExtensionBlockIndex,this->actualPointer);
    }

long StringPointerWrapper::hashValue()
    {
    long hash = 5381;
    int c;
    char *pointer = this->string();
    while ((c = *pointer++))
        {
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
        }
    return(hash);
    }

bool StringPointerWrapper::operator ==(StringPointerWrapper const &wrapper)
    {
    return(!strcmp(this->string(),wrapper.string()));
    }

Pointer StringPointerWrapper::extensionBlockPointer()
    {
    return(pointerAtIndexAtPointer(kStringExtensionBlockIndex,this->actualPointer));
    }
    
void StringPointerWrapper::setString(char const* string)
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
    Word totalWords = (totalBytes / kWordSize) + 1;
    extensionPointer = ObjectMemory::shared->allocateExtensionBlockWithCapacityInWords(totalWords);
    wrapper = new ExtensionBlockPointerWrapper(extensionPointer);
    wrapper->setCount(bytesNeeded);
    wrapper->setCapacity(totalBytes);
    strcpy((char*)wrapper->bytesPointer(),string);
    setPointerAtIndex(extensionPointer,kStringExtensionBlockIndex);
    delete wrapper;
    }

bool StringPointerWrapper::operator ==(Pointer const &pointer)
    {
    StringPointerWrapper wrapper = StringPointerWrapper(pointer);
    return(strcmp(wrapper.string(),this->string())==0);
    }

bool StringPointerWrapper::operator !=(StringPointerWrapper const &wrapper)
    {
    return(strcmp(wrapper.string(),this->string())!=0);
    }
