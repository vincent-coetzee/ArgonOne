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

//
// Extension Block slot indices
//
#define kExtensionBlockHeaderIndex (0)
#define kExtensionBlockTraitsIndex (1)
#define kExtensionBlockMutexIndex (2)
#define kExtensionBlockConditionIndex (3)
#define kExtensionBlockCountIndex (4)
#define kExtensionBlockCapacityIndex (5)
#define kExtensionBlockBytesIndex (6)
#define kExtensionBlockFixedSlotCount (7)

class ExtensionBlockPointerWrapper: public ObjectPointerWrapper
    {
    public:
        ExtensionBlockPointerWrapper(Pointer pointer);
        long count();
        long capacity();
        void setCount(long count);
        Pointer bytesPointer();
    };

#endif /* ExtensionBlockPointerWrapper_hpp */
