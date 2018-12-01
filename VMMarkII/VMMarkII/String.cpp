//
//  String.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "String.hpp"
#include <string.h>
#include <stdlib.h>

String::String(char const* string) 
    {
    long length = strlen(string);
    characterCount = length;
    if (length > 0)
        {
        char* stringPointer = new char[length + 1];
        strcpy(stringPointer,string);
        actualCharacters = stringPointer;
        }
    }

std::ostream& operator<<(std::ostream& out, const String &string)
    {
    out << string.actualCharacters;
    return(out);
    }

String::~String()
    {
    if (characterCount != 0 && actualCharacters != NULL)
        {
        delete [] actualCharacters;
        }
    actualCharacters = NULL;
    }

String& String::operator= (const String &string)
    {
    if (characterCount > 0)
        {
        delete [] actualCharacters;
        }
    char* newCharacters = new char[string.characterCount + 1];
    strcpy(newCharacters,string.characters());
    actualCharacters = newCharacters;
    characterCount = string.characterCount;
    return(*this);
    }

String& String::operator= (char const * string)
    {
    if (characterCount > 0)
        {
        delete [] actualCharacters;
        }
    long newCount = strlen(string) + 1;
    char* newCharacters = new char[newCount];
    strcpy(newCharacters,string);
    actualCharacters = newCharacters;
    characterCount = newCount - 1;
    return(*this);
    }

long String::count() const
    {
    return(characterCount);
    }

char* String::characters() const
    {
    return(actualCharacters);
    }

void String::print()
    {
    printf("%s\n",this->actualCharacters);
    }

long String::hashValue()
    {
    long hash = 5381;
    int c;
    char *pointer = this->actualCharacters;
    while ((c = *pointer++))
        {
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
        }
    return(hash);
    };

String String::operator +(char* characters)
    {
    long length = characterCount + strlen(characters) + 1;
    char* sum = new char[length];
    strcpy(sum,actualCharacters);
    strcat(sum,characters);
    String newString = String(sum);
    delete [] sum;
    return(newString);
    };

String String::operator +(String const &string)
    {
    long length = characterCount + strlen(string.characters()) + 1;
    char* sum = new char[length];
    strcpy(sum,actualCharacters);
    strcat(sum,string.characters());
    String newString = String(sum);
    delete[] sum;
    return(newString);
    }
