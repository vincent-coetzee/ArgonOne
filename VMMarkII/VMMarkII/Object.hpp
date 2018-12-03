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
#define kHandlerMarkerMask (((Word)1) << ((Word)55))
#define kHeaderForwardedMask (((Word)1) << ((Word)54))
#define kHeaderSlotCountMask (((Word)65535) << ((Word)38))
#define kHeaderGenerationMask (((Word)65535) << ((Word)22))
#define kHeaderTypeMask (((Word)65535) << ((Word)6))
#define kHeaderFlagsMask (((Word)63) << ((Word)0))

#define kHeaderMarkerShift ((Word)56)
#define kHandlerMarkerShift ((Word)55)
#define kHeaderForwardedShift ((Word)54)
#define kHeaderSlotCountShift ((Word)38)
#define kHeaderGenerationShift ((Word)22)
#define kHeaderTypeShift ((Word)6)
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
        bool isHandler();
        void setIsHandler(bool flag);
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
