//
//  VMMemory.h
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/24.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef VMMemory_h
#define VMMemory_h

#include <stdio.h>

typedef unsigned long long Word;
typedef Word* WordPointer;
typedef void* Pointer;



//
// Allocation routines, allocte various objects
// used by the VM
//
Pointer _Nonnull allocateObject(long slotCount,long type,long generation,TraitsPointer parents);

#endif /* VMMemory_h */
