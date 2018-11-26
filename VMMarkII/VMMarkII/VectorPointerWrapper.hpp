//
//  VectorPointerWrapper.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef VectorPointerWrapper_hpp
#define VectorPointerWrapper_hpp

#include <stdio.h>
#include "ArgonTypes.hpp"
#include "ObjectPointerWrapper.hpp"

class VectorPointerWrapper : public ObjectPointerWrapper
    {
    public:
        VectorPointerWrapper(Pointer pointer);
        long count();
        void setCount(long count);
        long capacity();
        void setCapacity(long capacity);
        Pointer extensionsBlockPointer();
        void setExtensionsBlockPointer(Pointer pointer);
        void addWordElement(Word element);
        void addPointerElement(Pointer element);
        Pointer pointerElementAtIndex(long index);
        Word wordElementAtIndex(long index);
        void growVector();
    };

#endif /* VectorPointerWrapper_hpp */