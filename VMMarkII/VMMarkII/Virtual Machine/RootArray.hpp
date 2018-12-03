//
//  RootArray.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef RootArray_hpp
#define RootArray_hpp

#include <stdio.h>
#include "CobaltPointers.hpp"
#include "CobaltTypes.hpp"

class Root
    {
    public:
        Pointer address;
        Pointer* rootOrigin;
    };

class RootArray
    {
    public:
        RootArray(long capacity);
        ~RootArray();
        void addRootAtOrigin(Pointer root,Pointer* rootOrigin);
        Root rootAtIndex(long index);
        void updateRoots();
        friend class ObjectMemory;
    private:
        void growArray();
        long capacity;
        long count;
        Root* elements;
    };
#endif /* RootArray_hpp */
