//
//  TraitsPointerWrapper.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef TraitsPointerWrapper_hpp
#define TraitsPointerWrapper_hpp

#include <stdio.h>
#include "CobaltTypes.hpp"
#include "ObjectPointerWrapper.hpp"
#include "String.hpp"

//
// Vector slot indices
//
#define kTraitsHeaderIndex (0)
#define kTraitsTraitsIndex (1)
#define kTraitsMonitorIndex (2)
#define kTraitsNameIndex (3)
#define kTraitsParentsCountIndex (4)
#define kTraitsSlotLayoutsCountIndex (5)

#define kTraitsFixedSlotCount (6)

#define kSlotsPerSlotLayout (3)

class SlotLayout
    {
    public:
        Pointer namePointer;
        Pointer traitsPointer;
        Word offsetAndFlags;
        void setOffset(long offset);
        void setFlags(long flags);
        long flags();
        long offset();
    };

class TraitsPointerWrapper : public ObjectPointerWrapper
    {
    public:
        TraitsPointerWrapper(Pointer pointer);
        long parentCount();
        long slotLayoutCount();
        char const *name();
        String stringName();
        Pointer parentAtIndex(int index);
        SlotLayout* slotLayoutAtName(Pointer name);
        SlotLayout* slotLayoutAtIndex(int index);
    };


#endif /* TraitsPointerWrapper_hpp */
