//
//  MapPointerWrapper.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/26.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef MapPointerWrapper_hpp
#define MapPointerWrapper_hpp

#include <stdio.h>
#include "ObjectPointerWrapper.hpp"
#include "CobaltPointers.hpp"
#include "Hashable.hpp"
#include "AssociationVectorPointerWrapper.hpp"

//
// Map slot indices
//
#define kMapHeaderIndex (0)
#define kMapTraitsIndex (1)
#define kMapMonitorIndex (2)
#define kMapCountIndex (3)
#define kMapCapacityIndex (4)
#define kMapAssociationVectorIndex (5)

#define kMapFixedSlotCount (6)

#define kMapNumberOfHashbuckets (109)
#define kMapInitialAssociationVectorSlotCount (199)
#define kMapAssociationVectorGrowthFactor 9/5

class MapPointerWrapper: public ObjectPointerWrapper
    {
    public:
        MapPointerWrapper(Pointer pointer);
        long count() const;
        void setCount(long count);
        long capacity();
        void setCapacity(long count);
        void addPointerForKey(Pointer pointer,Hashable* key);
        Pointer pointerForKey(Hashable* key);
        void addWordForKey(Word word,Hashable* key);
        Word wordForKey(Hashable* key);
    private:
        AssociationVectorPointerWrapper growAssociationVectorForHashbucket(long hashbucket,Pointer oldVectorPointer,long oldCapacity);
        Pointer createAssociationVectorForHashbucket(long hashbucket);
    };

#endif /* MapPointerWrapper_hpp */
