//
//  ArgonObject.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonObject_hpp
#define ArgonObject_hpp

#include <stdio.h>
#include "CobaltTypes.hpp"

#define kHeaderMarkerMask (((Word)1) << ((Word)56))
#define kHeaderForwardedMask (((Word)1) << ((Word)55))
#define kHeaderSlotCountMask (((Word)65535) << ((Word)39))
#define kHeaderGenerationMask (((Word)65535) << ((Word)23))
#define kHeaderTypeMask (((Word)65535) << ((Word)7))
#define kHeaderFlagsMask (((Word)127) << ((Word)0))

#define kHeaderMarkerShift ((Word)56)
#define kHeaderForwardedShift ((Word)55)
#define kHeaderSlotCountShift ((Word)39)
#define kHeaderGenerationShift ((Word)23)
#define kHeaderTypeShift ((Word)7)
#define kHeaderFlagsShift ((Word)0)

struct Object
    {
    public:
        Word header;
        Pointer traits;
        Pointer monitor;
    public:
        Object();
        Object(Word headerValue);
        ~Object();
        bool isHeader();
        void setIsHeader(bool value);
        bool isForwarded();
        void setIsForwarded(bool flag);
        long slotCount();
        void setSlotCount(long count);
        long generation();
        void setGeneration(long count);
        long type();
        void setType(long type);
        long flags();
        void setFlags(long flags);
    };
    
#endif /* ArgonObject_hpp */
