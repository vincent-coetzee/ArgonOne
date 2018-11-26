//
//  main.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include <iostream>
#include <pthread.h>

#include "ArgonTypes.hpp"
#include "MachineInstruction.hpp"
#include "Object.hpp"
#include "Memory.hpp"
#include "ObjectPointerWrapper.hpp"
#include "StringPointerWrapper.hpp"
#include "VectorPointerWrapper.hpp"

void testArgonInstruction(void);
void testObjects(void);
void testTagging(void);
void testRawPointers(void);
void testMemory(void);
void testPointers(void);
void testStringPointers(void);
void testVectorsAndGrowing(void);

int main(int argc, const char * argv[])
    {
    // insert code here...
    std::cout << "Hello, World!\n";
    std::cout << "Size of mutex is " << sizeof(pthread_mutex_t) << "\n";
    std::cout << "Size of cond is " << sizeof(pthread_mutex_t) << "\n";
    std::cout << "Size of Word is " << sizeof(Word) << "\n";
    std::cout << "Size of char is " << sizeof(char) << "\n";
    testVectorsAndGrowing();
    testStringPointers();
    testPointers();
    testMemory();
    testTagging();
    testObjects();
    testArgonInstruction();
    return 0;
    };

void testVectorsAndGrowing()
    {
    Pointer vector1 = Memory::shared->allocateVectorWithCapacityInWords(20);
    VectorPointerWrapper wrapper = VectorPointerWrapper(vector1);
    for (int index=0;index<50;index++)
        {
        wrapper.addWordElement(index);
        printf("Added %ld to vector\n",(long)index);
        printf("The count of the vector is %ld\n",wrapper.count());
        }
    for (int index=0;index<50;index++)
        {
        printf("Looking at index %ld\n",(long)index);
        printf("Found %lld \n",wrapper.wordElementAtIndex(index));
        }
    }
    
void testStringPointers()
    {
    StringPointerWrapper wrapper = StringPointerWrapper(Memory::shared->allocateString("This is a somewhat long test string that can be used where a string is needed"));
    printf("The string is %s\n",wrapper.string());
    };

void testPointers()
    {
    Pointer block = Memory::shared->allocateBlock(320);
    setWordAtIndexAtPointer(211,0,block);
    Word testWord = wordAtIndexAtPointer(0,block);
    assert(testWord == 211);
    setWordAtIndexAtPointer(510000,3,block);
    testWord = wordAtIndexAtPointer(3,block);
    assert(testWord == 510000);
    setPointerAtIndexAtPointer(block,0,block);
    Pointer testPointer = pointerAtIndexAtPointer(0,block);
    assert(testPointer == block);
    }

void testMemory()
    {
    Pointer objectPointer = Memory::shared->allocateObject(10, kTypeVector,128, NULL);
    ObjectPointerWrapper wrapper(objectPointer);
    Word header =  wrapper.wordAtIndex(0);
    char string[200];
    MachineInstruction::bitStringFor(string, objectPointer);
    printf("Object pointer : %s\n",string);
    MachineInstruction::bitStringFor(string, header);
    printf("Object header  : %s\n",string);
    char newString[200] = "This is a string";
    Pointer stringPointer = Memory::shared->allocateString(newString);
    StringPointerWrapper stringWrapper(stringPointer);
    stringWrapper.count();
    printf("String count is %ld string is %s\n",stringWrapper.count(),stringWrapper.string());
    };

void testRawPointers()
    {
    };
    
void testTagging()
    {
    Object* pointer = new Object();
    Pointer taggedPointer = taggedPointer(pointer,kBitsObject);
    Pointer untaggedPointer = untaggedPointer(taggedPointer);
    char string[200];
    printf("Object Pointer   : %s\n",MachineInstruction::bitStringFor(string,(unsigned char*)pointer));
    printf("Tagged Pointer   : %s\n",MachineInstruction::bitStringFor(string,taggedPointer));
    printf("Untagged Pointer : %s\n",MachineInstruction::bitStringFor(string,untaggedPointer));
    };

void testObjects()
    {
    std::cout << "Size of base Object is " << sizeof(Object) << "\n";
    Object* firstObject = new Object();
    firstObject->setType(kTypeVector);
    firstObject->setIsForwarded(true);
    firstObject->setGeneration(1);
    firstObject->setFlags(128);
    firstObject->setSlotCount(11);
    Word tempObject = (Word)firstObject;
    Object* second = (Object*)tempObject;
    assert(second->type() == kTypeVector);
    assert(second->isForwarded() == 1);
    assert(second->generation() == 1);
    assert(second->flags() == 128);
    assert(second->slotCount() == 11);
    };

void testArgonInstruction()
    {
    MachineInstruction* instruction = new MachineInstruction(0);
    instruction->setMode(InstructionMode::address);
    instruction->setCode(InstructionCode::HAND);
    instruction->setRegister1(23);
    instruction->setRegister2(476);
    instruction->setRegister3(1);
    instruction->setImmediate(-427000);
    instruction->setAddress(467363478378);
    assert(instruction->mode() == InstructionMode::address);
    assert(instruction->code() == InstructionCode::HAND);
    assert(instruction->register1() == 23);
    assert(instruction->register2() != 476);
    assert(instruction->register3() == 1);
    assert(instruction->immediate() == -427000);
    assert(instruction->address() == 467363478378);
    }
