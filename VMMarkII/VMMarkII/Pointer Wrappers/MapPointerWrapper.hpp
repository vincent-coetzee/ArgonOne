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
#include "ArgonPointers.hpp"
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
#define kMapHashbucketCountIndex (5)
#define kMapAssociationVectorIndex (6)

#define kMapFixedSlotCount (7)

#define kMapHashBucketPrime (109)
#define kMapHashBucketLengthPrime (199)

class MapPointerWrapper: public ObjectPointerWrapper
    {
    public:
        MapPointerWrapper(Pointer pointer);
        long count() const;
        void setCount(long count);
        long capacity();
        void setCapacity(long count);
        long hashbucketCount();
        void setHashbucketCount(long count);
        void addPointerForKey(Pointer pointer,Hashable key);
        Pointer pointerForKey(Hashable key);
        void addWordForKey(Word word,Hashable key);
        Word wordForKey(Hashable key);
    private:
        AssociationVectorPointerWrapper growAssociationVector(AssociationVectorPointerWrapper wrapper);
        Pointer createAssociationVector();
    };

#endif /* MapPointerWrapper_hpp */
