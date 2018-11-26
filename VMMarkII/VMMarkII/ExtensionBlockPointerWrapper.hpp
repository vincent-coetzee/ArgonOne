//
//  ExtensionBlockPointerWrapper.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ExtensionBlockPointerWrapper_hpp
#define ExtensionBlockPointerWrapper_hpp

#include <stdio.h>
#include "ObjectPointerWrapper.hpp"
#include "Memory.hpp"


class ExtensionBlockPointerWrapper: public ObjectPointerWrapper
    {
    public:
        ExtensionBlockPointerWrapper(Pointer pointer);
        long count();
        long capacity();
        void setCapacity(long capacity);
        void setCount(long count);
        Pointer bytesPointer();
    };

#endif /* ExtensionBlockPointerWrapper_hpp */
