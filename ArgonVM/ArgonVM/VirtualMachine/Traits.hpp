//
//  Traits.hpp
//  ArgonVM
//
//  Created by Vincent Coetzee on 2018/11/24.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef Traits_hpp
#define Traits_hpp

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <string.h>
#include <pthread.h>

typedef unsigned long long Word;
typedef Word* WordPointer;
typedef void* Pointer;

#define kTagInstance (((Word)4) << ((Word)59))
#define kTagForwarded (((Word)1) << ((Word)58))
#define kTagSlotCount (((Word)65535) << ((Word)32))
#define kTagGeneration (((Word)255) << ((Word)24))
#define kTagType (((Word)255) << ((Word)8))


class ArgonObject
    {
    public:
        ArgonObject(int slotCount,int generationCount,int type,Pointer traits)
            {
            this->headerUpperPadding = 0;
            this->headerInstance = 1;
            this->headerForwarded = 0;
            this->headerSlotCount = slotCount;
            this->headerType = type;
            this->headerGeneration = 1;
            this->headerLowerPadding = 0;
            this->slotList= new Word[slotCount];
            this->traits = traits;
            };
        
        virtual Word wordAtIndex(int index)
            {
            return(slotList[index]);
            };
        
        virtual Pointer pointerAtIndex(int index)
            {
            return((void*)slotList[index]);
            };
        
    private:
        Word headerUpperPadding : 4;
        Word headerInstance     : 1;
        Word headerForwarded    : 1;
        Word headerSlotCount    : 16;
        Word headerType         : 16;
        Word headerGeneration   : 16;
        Word headerLowerPadding : 10;
        Pointer traits;
        WordPointer slotList;
    };



class ArgonTraits : public ArgonObject
    {
    };
    
class ArgonString : public ArgonObject
    {
    };

class String
    {
    public:
        String(char* newString)
            {
            char* stringPointer = (char*)malloc(strlen(newString) + 1);
            strcpy(stringPointer,newString);
            this->string = stringPointer;
            };
        
        ~String()
            {
            free(string);
            };
        
        char* stringValue()
            {
            return(string);
            }
        
    private:
        char* string;
    };

class Traits
    {
    
    };

#endif /* Traits_hpp */
