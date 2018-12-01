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
#include "CobaltTypes.hpp"
#include "Hashable.hpp"
#include <iostream>

class String: public Hashable
    {
    public:
        String(char const* string);
        ~String();
        long count() const;
        String operator +(char* characters);
        String operator +(String const &string);
        char* characters() const;
        long virtual hashValue() override;
        void print();
        friend std::ostream& operator<<(std::ostream& out, const String &string);
        String& operator= (const String &string);
        String& operator= (char const * string);
    private:
        char* actualCharacters;
        long characterCount;
    };

#endif /* String_hpp */
