//
//  VMMemory.c
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/24.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "ObjectMemory.h"

#define kTagInstance (((Word)4) << ((Word)59))
#define kTagForwarded (((Word)1) << ((Word)58))
#define kTagSlotCount (((Word)65535) << ((Word)32))
#define kTagGeneration (((Word)255) << ((Word)24))
#define kTagType (((Word)255) << ((Word)8))

 Pointer _Nonnull allocateObject(long slotCount,long type,long generation)
    {
    return(malloc(4000));
    }
