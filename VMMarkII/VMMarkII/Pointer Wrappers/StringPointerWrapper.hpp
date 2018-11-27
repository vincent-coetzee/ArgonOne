//
//  StringPointerWrapper.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef StringPointerWrapper_hpp
#define StringPointerWrapper_hpp

#include <stdio.h>
#include "ArgonTypes.hpp"
#include "ObjectPointerWrapper.hpp"
#include "Hashable.hpp"

//
// String slot indices
//
#define kStringHeaderIndex 0
#define kStringTraitsIndex 1
#define kStringMonitorIndex 2
#define kStringCountIndex 3
#define kStringExtensionBlockIndex 4
#define kStringFixedSlotCount 5
//
// The class
//
class StringPointerWrapper : public ObjectPointerWrapper,public Hashable
    {
    public:
        StringPointerWrapper(Pointer pointer);
        long count();
        char* string() const;
        void setString(char* string);
        void setExtensionBlockPointer(Pointer value);
        Pointer extensionBlockPointer();
    public:
        long virtual hashValue();
        bool virtual operator ==(StringPointerWrapper const &wrapper);
    };
    
#endif /* StringPointerWrapper_hpp */


