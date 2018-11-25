//
//  ArgonObject.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "Object.hpp"

#define kHeaderReservedMask (((Word)7) << ((Word)57))
#define kHeaderForwardedMask (((Word)1) << ((Word)56))
#define kHeaderSlotCountMask (((Word)65535) << ((Word)40))
#define kHeaderGenerationMask (((Word)65535) << ((Word)24))
#define kHeaderTypeMask (((Word)65535) << ((Word)8))
#define kHeaderFlagsMask (((Word)255) << ((Word)0))

#define kHeaderReservedShift ((Word)57)
#define kHeaderForwardedShift ((Word)56)
#define kHeaderSlotCountShift ((Word)40)
#define kHeaderGenerationShift ((Word)24)
#define kHeaderTypeShift ((Word)8)
#define kHeaderFlagsShift ((Word)0)

Object::_ArgonObject()
    {
    header = 0;
    };

bool Object::isForwarded()
    {
    return(((header & kHeaderForwardedMask) >> kHeaderForwardedShift) == 1 ? true : false);
    };

void Object::setIsForwarded(bool flag)
    {
    Word bit = ((flag == true) ? 1 : 0);
    bit <<= kHeaderForwardedShift;
    bit &= kHeaderForwardedMask;
    header &= ~kHeaderForwardedMask;
    header |= bit;
    };

long Object::slotCount()
    {
    return((long)(header & kHeaderSlotCountMask) >> kHeaderSlotCountShift);
    };

void Object::setSlotCount(long count)
    {
    Word wordCount = count;
    wordCount <<= kHeaderSlotCountShift;
    wordCount &= kHeaderSlotCountMask;
    header &= ~kHeaderSlotCountMask;
    header |= wordCount;
    };

long Object::generation()
    {
    return((long)(header & kHeaderGenerationMask) >> kHeaderGenerationShift);
    };

void Object::setGeneration(long count)
    {
    Word wordCount = count;
    wordCount <<= kHeaderGenerationShift;
    wordCount &= kHeaderGenerationMask;
    header &= ~kHeaderGenerationMask;
    header |= wordCount;
    };

long Object::type()
    {
return((long)(header & kHeaderTypeMask) >> kHeaderTypeShift);
    };

void Object::setType(long type)
    {
    Word wordCount = type;
    wordCount <<= kHeaderTypeShift;
    wordCount &= kHeaderTypeMask;
    header &= ~kHeaderTypeMask;
    header |= wordCount;
    };

long Object::flags()
    {
    return((long)(header & kHeaderFlagsMask) >> kHeaderFlagsShift);
    }

void Object::setFlags(long flags)
    {
    Word wordCount = flags;
    wordCount <<= kHeaderFlagsShift;
    wordCount &= kHeaderFlagsMask;
    header &= ~kHeaderFlagsMask;
    header |= wordCount;
    }
