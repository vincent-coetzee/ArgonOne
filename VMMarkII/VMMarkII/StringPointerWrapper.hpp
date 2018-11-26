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

class StringPointerWrapper : public ObjectPointerWrapper
    {
    public:
        StringPointerWrapper(Pointer pointer);
        long count();
        char* string();
        void setString(char* string);
        void setExtensionBlockPointer(Pointer value);
        Pointer extensionBlockPointer();
    };
    
#endif /* StringPointerWrapper_hpp */


