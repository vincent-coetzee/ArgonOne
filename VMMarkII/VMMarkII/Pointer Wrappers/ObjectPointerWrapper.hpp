//
//  ObjectPointer.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ObjectPointer_hpp
#define ObjectPointer_hpp

#include <stdio.h>
#include "ArgonTypes.hpp"
#include "Object.hpp"

class ObjectPointerWrapper
    {
    public:
        ObjectPointerWrapper(Pointer pointer);
        long slotCount();
        void setSlotCount(long count);
        bool isForwarded();
        void setIsForwarded(bool flag);
        long type();
        void setType(long type);
        long flags();
        void setFlags(long flags);
        long generation();
        void setGeneration(long count);
        Pointer traits();
        Pointer mutex();
        Pointer condition();
        Word wordAtIndex(long index);
        Pointer pointerAtIndex(long index) const;
        void setWordAtIndex(Word word,long index);
        void setPointerAtIndex(Pointer pointer,long index);
    public:
        Pointer actualPointer;
        Object* objectPointer;
    };

#endif /* ObjectPointer_hpp */
