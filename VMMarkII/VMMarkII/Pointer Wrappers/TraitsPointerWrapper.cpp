//
//  TraitsPointerWrapper.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "TraitsPointerWrapper.hpp"
#include "CobaltPointers.hpp"
#include "StringPointerWrapper.hpp"
#include "ExtensionBlockPointerWrapper.hpp"

#define kSlotLayoutOffsetMask ((Word)65535)
#define kSlotLayoutFlagsBits ((Word)65535)
#define kSlotLayoutFlagsMask (((Word)65535) << ((Word)16))
#define kSlotLayoutFlagsShift ((Word)16)

long SlotLayout::offset()
    {
    return((long)offsetAndFlags & kSlotLayoutOffsetMask);
    }

long SlotLayout::flags()
    {
    return((long)((offsetAndFlags & kSlotLayoutFlagsMask) >> kSlotLayoutFlagsShift));
    }

void SlotLayout::setFlags(long flags)
    {
    flags = flags & kSlotLayoutFlagsBits;
    offsetAndFlags = offsetAndFlags & ~kSlotLayoutFlagsMask;
    offsetAndFlags = offsetAndFlags | (flags << kSlotLayoutFlagsShift);
    }

void SlotLayout::setOffset(long offset)
    {
    offset = offset & kSlotLayoutOffsetMask;
    offsetAndFlags = offsetAndFlags & ~kSlotLayoutOffsetMask;
    offsetAndFlags = offsetAndFlags | offset;
    }

TraitsPointerWrapper::TraitsPointerWrapper(Pointer pointer) : ObjectPointerWrapper(pointer)
    {
    }

long TraitsPointerWrapper::parentCount()
    {
    return(wordAtIndexAtPointer(kTraitsParentsCountIndex,this->actualPointer));
    }

char const *TraitsPointerWrapper::name()
    {
    Pointer namePointer = untaggedPointer(pointerAtIndexAtPointer(kTraitsNameIndex,this->actualPointer));
    Pointer blockPointer = untaggedPointer(pointerAtIndexAtPointer(kStringExtensionBlockIndex,namePointer));
    WordPointer wordPointer = ((WordPointer)blockPointer) + kExtensionBlockBytesIndex;
    char const * charPointer = (char*)wordPointer;
    return(charPointer);
    }

String TraitsPointerWrapper::stringName()
    {
    return(String(this->name()));
    }
    
long TraitsPointerWrapper::slotLayoutCount()
    {
    return(wordAtIndexAtPointer(kTraitsSlotLayoutsCountIndex,this->actualPointer));
    }

Pointer TraitsPointerWrapper::parentAtIndex(int index)
    {
    long offset = index + kTraitsFixedSlotCount;
    return(pointerAtIndexAtPointer(offset,this->actualPointer));
    }

SlotLayout* TraitsPointerWrapper::slotLayoutAtName(Pointer name)
    {
    return(NULL);
    }
    
SlotLayout* slotLayoutAtIndex(int index)
    {
    return(NULL);
    }
