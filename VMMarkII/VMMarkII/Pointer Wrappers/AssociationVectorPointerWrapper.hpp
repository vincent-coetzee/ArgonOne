//
//  AssociationVectorPointerWrapper.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef AssociationVectorPointerWrapper_hpp
#define AssociationVectorPointerWrapper_hpp

#include <stdio.h>
#include "ObjectPointerWrapper.hpp"
#include "ArgonPointers.hpp"

//
// Vector slot indices
//
#define kAssociationVectorHeaderIndex (0)
#define kAssociationVectorTraitsIndex (1)
#define kAssociationVectorMonitorIndex (2)
#define kAssociationVectorCountIndex (3)
#define kAssociationVectorCapacityIndex (4)

#define kAssociationVectorFixedSlotCount (5)

class AssociationVectorPointerWrapper: public ObjectPointerWrapper
    {
    public:
        AssociationVectorPointerWrapper(Pointer pointer);
        long copyContentsOf(Pointer pointer);
        long count();
        void setCount(long count);
        long capacity();
        void setCapacity(long count);
        void addAssociation(long hash,Pointer pointer);
        void addWordAssociation(long hash,Word word);
        Pointer pointerAtHash(long hash);
        Word wordAtHash(long hash);
        void deleteAtHash(long hash);
    };

#endif /* AssociationVectorPointerWrapper_hpp */
