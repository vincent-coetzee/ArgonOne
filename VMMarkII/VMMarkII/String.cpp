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

String::String(char* string)
    {
    long length = strlen(string);
    characterCount = length;
    char* stringPointer = new char[length + 1];
    strcpy(stringPointer,string);
    actualCharacters = stringPointer;
    }
    
String::~String()
    {
    if (actualCharacters != NULL)
        {
        delete actualCharacters;
        }
    actualCharacters = NULL;
    }

long String::count() const
    {
    return(characterCount);
    }

bool String::operator ==(String const &string)
    {
    return(!strcmp(this->actualCharacters,string.actualCharacters));
    }

char* String::characters() const
    {
    return(actualCharacters);
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
    strcpy(sum,characters);
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
