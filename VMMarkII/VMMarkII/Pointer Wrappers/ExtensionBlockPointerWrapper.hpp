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
#include "ObjectMemory.hpp"

//
// Extension Block slot indices
//
#define kExtensionBlockHeaderIndex (0)
#define kExtensionBlockTraitsIndex (1)
#define kExtensionBlockMonitorIndex (2)
#define kExtensionBlockCountIndex (3)
#define kExtensionBlockCapacityIndex (4)
#define kExtensionBlockBytesIndex (5)

#define kExtensionBlockFixedSlotCount (6)


class ExtensionBlockPointerWrapper: public ObjectPointerWrapper
    {
    public:
        ExtensionBlockPointerWrapper(Pointer pointer);
        long count();
        long capacity();
        void setCapacity(long capacity);
        void setCount(long count);
        Pointer bytesPointer() const;
    };

#endif /* ExtensionBlockPointerWrapper_hpp */
