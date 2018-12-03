//
//  RootArray.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "RootArray.hpp"
#include <stdlib.h>
#include <string.h>

RootArray::RootArray(long capacity)
    {
    count = 0;
    this->capacity = capacity;
    this->elements = new Root[capacity];
    }

RootArray::~RootArray()
    {
    delete [] elements;
    }

void RootArray::addRootAtOrigin(Pointer root,Pointer* rootOrigin)
    {
    Root aRoot;
    
    aRoot.address = root;
    aRoot.rootOrigin = rootOrigin;
    if (count >= capacity - 1)
        {
        growArray();
        }
    elements[count] = aRoot;
    count++;
    }

void RootArray::updateRoots()
    {
    for (long index=0;index<count;index++)
        {
        Root aRoot = elements[index];
        *aRoot.rootOrigin = taggedObjectPointer(aRoot.address);
        }
    }

void RootArray::growArray()
    {
    long newCapacity = capacity * 2;
    Root* newElements = new Root[newCapacity];
    memcpy(newElements,elements,count*sizeof(Root));
    delete [] elements;
    elements = newElements;
    capacity = newCapacity;
    }
