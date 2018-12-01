//
//  ArgonMemory.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonMemory_hpp
#define ArgonMemory_hpp

#include <stdio.h>
#include "CobaltTypes.hpp"
#include "MemorySpace.hpp"
#include "String.hpp"
#include "TraitsPointerWrapper.hpp"

class Mutex;
class RootArray;

class ObjectMemory
    {
    public:
        ObjectMemory(long capacity);
        ~ObjectMemory();
        Pointer allocateObject(int slotCount,int type,int flags,Pointer traits);
        Pointer allocateString(char const* string);
        Pointer allocateString(String string);
        Pointer allocateExtensionBlockWithCapacityInWords(long capacity);
        Pointer allocateMap(int capacity);
        Pointer allocateTraits(char const* name,Pointer* parents,long parentsCount,SlotLayout* slots,long slotsCount);
        Pointer allocateTraits(String name,Pointer* parents,long parentsCount,SlotLayout* slots,long slotsCount);
        Pointer allocateVectorWithCapacityInWords(long capacity);
        Pointer allocateMap();
        Pointer allocateAssociationVectorOfSizeInWords(long wordCount);
        void collectGarbage(RootArray* rootArray);
    public:
        static ObjectMemory* shared;
        void dumpWordsAtPointerForLength(Pointer pointer,long length);
        void dumpBusyWords();
    private:
        void copySpaceToSpace(MemorySpace* fromSpace,MemorySpace* toSpace);
        void copyRootsFromTo(RootArray* rootArray,MemorySpace* fromSpace,MemorySpace* toSpace);
        inline Pointer copyRoot(Pointer outerRoot,Pointer* freePointer);
        MemorySpace* fromSpace;
        MemorySpace* toSpace;
        MemorySpace* finalSpace;
        RootArray* rootArray;
        Mutex* mutex;
    private:
        void initBaseTraits();
    };
    
#endif /* ArgonMemory_hpp */
