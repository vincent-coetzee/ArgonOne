//
//  String.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef String_hpp
#define String_hpp

#include <stdio.h>
#include "ArgonTypes.hpp"
#include "Hashable.hpp"

class String: public Hashable
    {
    public:
        String(char* string);
        ~String();
        long count() const;
        bool virtual operator ==(String const &string);
        String operator +(char* characters);
        String operator +(String const &string);
        char* characters() const;
        long virtual hashValue();
    private:
        char* actualCharacters;
        long characterCount;
    };

#endif /* String_hpp */
