//
//  main.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include <iostream>
#include <pthread.h>

#include "CobaltTypes.hpp"
#include "MachineInstruction.hpp"
#include "Object.hpp"
#include "ObjectMemory.hpp"
#include "ObjectPointerWrapper.hpp"
#include "StringPointerWrapper.hpp"
#include "VectorPointerWrapper.hpp"
#include "CobaltPointers.hpp"
#include "AssociationVectorPointerWrapper.hpp"
#include "MapPointerWrapper.hpp"
#include "String.hpp"
#include "RootArray.hpp"

void testArgonInstruction(void);
void testObjects(void);
void testTagging(void);
void testRawPointers(void);
void testMemory(void);
void testPointers(void);
void testStringPointers(void);
void testVectorsAndGrowing(void);
void testMaps(void);
void testTraits(void);
void testObjectMemory(void);

int main(int argc, const char * argv[])
    {
    // insert code here...
    std::cout << "Hello, World!\n";
    std::cout << "Size of mutex is " << sizeof(pthread_mutex_t) << "\n";
    std::cout << "Size of cond is " << sizeof(pthread_mutex_t) << "\n";
    std::cout << "Size of Word is " << sizeof(Word) << "\n";
    std::cout << "Size of char is " << sizeof(char) << "\n";
    testTraits();
    testObjectMemory();
    testStringPointers();
    testMaps();
    testVectorsAndGrowing();
    testPointers();
    testMemory();
    testTagging();
    testObjects();
    testArgonInstruction();
    return 0;
    };

void testObjectMemory()
    {
    ObjectMemory::shared = new ObjectMemory(10*1024*1024);
    ObjectMemory* objectMemory = ObjectMemory::shared;
    Pointer traitsMap = objectMemory->allocateMap();
    MapPointerWrapper mapWrapper = MapPointerWrapper(traitsMap);
    Pointer behavior = objectMemory->allocateTraits("Argon::Behavior", NULL, 0, NULL,0);
    String aString = String("Argon::Behavior");
    mapWrapper.addPointerForKey(behavior, &aString);
    Pointer voidTraits = objectMemory->allocateTraits("Argon::Void", NULL, 0, NULL,0);
    aString = String("Argon::Void");
    mapWrapper.addPointerForKey(voidTraits, &aString);
    aString = String("Argon::Number");
    Pointer traits[10];
    traits[0] = behavior;
    Pointer numberTraits = objectMemory->allocateTraits(aString.characters(),traits, 1, NULL,0);
    mapWrapper.addPointerForKey(numberTraits, &aString);
    aString = String("Argon::Integer");
    traits[0] = numberTraits;
    Pointer integerTraits = objectMemory->allocateTraits(aString.characters(),traits, 1, NULL,0);
    mapWrapper.addPointerForKey(integerTraits, &aString);
    aString = "Argon::Behavior";
    Pointer newTraits = mapWrapper.pointerForKey(&aString);
    std::cout << newTraits;
    Pointer traitsMapBefore = traitsMap;
    RootArray* rootArray = new RootArray(50);
    rootArray->addRootAtOrigin(traitsMap, &traitsMap);
    ObjectMemory::shared->dumpBusyWords();
    objectMemory->collectGarbage(rootArray);
    delete rootArray;
    printf("Traits Map before GC %010lX \n",(unsigned long)traitsMapBefore);
    printf("Traits Map after GC %010lX \n",(unsigned long)traitsMap);
    mapWrapper = MapPointerWrapper(traitsMap);
    String firstName = String("Argon::Behavior");
    Pointer traitsObject = mapWrapper.pointerForKey(&firstName);
    TraitsPointerWrapper secondWrapper = TraitsPointerWrapper(traitsObject);
    std::cout << "Lookup of Argon::Behavior found -> " << secondWrapper.name() << "\n";
    firstName = "Argon::Number";
    Pointer someTraits = mapWrapper.pointerForKey(&firstName);
    TraitsPointerWrapper thirdWrapper = TraitsPointerWrapper(someTraits);
    std::cout << "Lookup of Argon::Number found -> " << thirdWrapper.name() << "\n";
    traitsMapBefore = traitsMap;
    rootArray = new RootArray(50);
    rootArray->addRootAtOrigin(traitsMap, &traitsMap);
    objectMemory->collectGarbage(rootArray);
    printf("Traits Map before GC %010lX \n",(unsigned long)traitsMapBefore);
    printf("Traits Map after GC %010lX \n",(unsigned long)traitsMap);
    mapWrapper = MapPointerWrapper(traitsMap);
    firstName = String("Argon::Behavior");
    traitsObject = mapWrapper.pointerForKey(&firstName);
    secondWrapper = TraitsPointerWrapper(traitsObject);
    std::cout << "Lookup of Argon::Behavior found -> " << secondWrapper.name() << "\n";
    firstName = "Argon::Number";
    someTraits = mapWrapper.pointerForKey(&firstName);
    thirdWrapper = TraitsPointerWrapper(someTraits);
    std::cout << "Lookup of Argon::Number found -> " << thirdWrapper.name() << "\n";
    }

void testTraits()
    {
    Pointer traitsMap = ObjectMemory::shared->allocateMap();
    MapPointerWrapper mapWrapper = MapPointerWrapper(traitsMap);
    Pointer behavior = ObjectMemory::shared->allocateTraits("Argon::Behavior", NULL, 0, NULL,0);
    String aString = String("Argon::Behavior");
    std::cout << aString.hashValue();
    mapWrapper.addPointerForKey(behavior, &aString);
    Pointer voidTraits = ObjectMemory::shared->allocateTraits("Argon::Void", NULL, 0, NULL,0);
    aString = String("Argon::Void");
    mapWrapper.addPointerForKey(voidTraits, &aString);
    aString = String("Argon::Number");
    Pointer traits[10];
    traits[0] = behavior;
    Pointer numberTraits = ObjectMemory::shared->allocateTraits(aString.characters(),traits, 1, NULL,0);
    mapWrapper.addPointerForKey(numberTraits, &aString);
    aString = String("Argon::Integer");
    traits[0] = numberTraits;
    Pointer integerTraits = ObjectMemory::shared->allocateTraits(aString.characters(),traits, 1, NULL,0);
    mapWrapper.addPointerForKey(integerTraits, &aString);
    aString = "Argon::Behavior";
    std::cout << aString.hashValue();
    Pointer newTraits = mapWrapper.pointerForKey(&aString);
    std::cout << "The name of this traits is " << TraitsPointerWrapper(newTraits).stringName();
    }

void testMaps()
    {
    char chunk[1000];
    
    Pointer mainPointer = (Pointer)chunk;
    Pointer aPointer = (Pointer)10;
    setPointerAtIndexAtPointer(aPointer,0,mainPointer);
    aPointer = (Pointer)20;
    setPointerAtIndexAtPointer(aPointer,1,mainPointer);
    assert(wordAtIndexAtPointer(0,mainPointer) == 10);
    assert(wordAtIndexAtPointer(1,mainPointer) == 20);
    assert(pointerAtIndexAtPointer(0,mainPointer) == (Pointer)10);
    assert(pointerAtIndexAtPointer(1,mainPointer) == (Pointer)20);
    setWordAtIndexAtPointer(100,2,mainPointer);
    setWordAtIndexAtPointer(200,3,mainPointer);
    assert(wordAtIndexAtPointer(2,mainPointer) == 100);
    assert(wordAtIndexAtPointer(3,mainPointer) == 200);
    Pointer associations = ObjectMemory::shared->allocateAssociationVectorOfSizeInWords(200);
    AssociationVectorPointerWrapper wrapper1 = AssociationVectorPointerWrapper(associations);
    ObjectMemory::shared->dumpWordsAtPointerForLength(associations, 10);
    wrapper1.count();
    wrapper1.capacity();
    assert(wrapper1.count() == 0);
    for (long index=0;index<190;index++)
        {
        wrapper1.addWordAssociation(index, index+1);
        }
    for (long index=0;index<190;index++)
        {
        Word aWord = wrapper1.wordAtHash(index);
        std::cout << "Index = "  << index << " word found is " << aWord << "\n";
        assert(aWord == index+1);
        }
    Pointer mapPointer = ObjectMemory::shared->allocateMap();
    MapPointerWrapper map = MapPointerWrapper(mapPointer);
    assert(map.count() == 0);
    String string1 = String((char*)"This is a new string");
    map.addWordForKey(201010,&string1);
    String string2 = String((char*)"This is a new string");
    Word answer = map.wordForKey(&string2);
    std::cout << answer;
    assert(map.count() == 1);
    string1 = String((char*)"This is a newer string than the old one");
    map.addWordForKey(41619873,&string1);
    string2 = String((char*)"This is a newer string than the old one");
    answer = map.wordForKey(&string2);
    assert(answer == 41619873);
    std::cout << answer;
    for (long index=100;index<41223;index++)
        {
        char array[300];
        sprintf(array, "%ld",index);
        string1 = String(array);
        if (index == 21111)
            {
            printf("halt");
            }
        map.addWordForKey(index,&string1);
        }
    for (long index=100;index<41223;index++)
        {
        char array[300];
        sprintf(array, "%ld",index);
        string1 = String(array);
        answer = map.wordForKey(&string1);
        assert(answer == index);
        }
    }

void testVectorsAndGrowing()
    {
    Pointer vector1 = ObjectMemory::shared->allocateVectorWithCapacityInWords(20);
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
    StringPointerWrapper wrapper = StringPointerWrapper(ObjectMemory::shared->allocateString((char*)"This is a somewhat long test string that can be used where a string is needed"));
    printf("The string is %s\n",wrapper.string());
    StringPointerWrapper second = StringPointerWrapper(ObjectMemory::shared->allocateString((char*)"This is a test string string is needed"));
    assert(wrapper != second);
    StringPointerWrapper third = StringPointerWrapper(ObjectMemory::shared->allocateString((char*)"This is a somewhat long test string that can be used where a string is needed"));
    assert(third == wrapper);
    assert(third != second);
    };

void testPointers()
    {
    char space[1024];
    Pointer block = (Pointer)space;
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
    Pointer objectPointer = ObjectMemory::shared->allocateObject(10, kTypeVector,128, NULL);
    ObjectPointerWrapper wrapper(objectPointer);
    Word header =  wrapper.wordAtIndex(0);
    char string[200];
    char newString[200] = "This is a string";
    Pointer stringPointer = ObjectMemory::shared->allocateString(newString);
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
    Pointer taggedPointer = taggedObjectPointer(pointer);
    Pointer untaggedPointer = untaggedPointer(taggedPointer);
    assert(isTaggedObjectPointer(taggedPointer));
    assert(!isTaggedObjectPointer(untaggedPointer));
    assert(tagOfPointer(taggedPointer) == (kBitsObject>>kBitsShift));
    };

void testObjects()
    {
    std::cout << "Size of base Object is " << sizeof(Object) << "\n";
    Object* firstObject = new Object();
    firstObject->setType(kTypeVector);
    firstObject->setIsForwarded(true);
    firstObject->setGeneration(1);
    firstObject->setFlags(31);
    firstObject->setSlotCount(11);
    Word tempObject = (Word)firstObject;
    Object* second = (Object*)tempObject;
    assert(second->type() == kTypeVector);
    assert(second->isForwarded() == 1);
    assert(second->generation() == 1);
    assert(second->flags() == 31);
    assert(second->slotCount() == 11);
    Word data[10];
    firstObject = (Object*)data;
    firstObject->setType(kTypeVector);
    firstObject->setGeneration(300);
    firstObject->setSlotCount(10);
    firstObject->setIsForwarded(true);
    Word copyData[10];
    for (int index=0;index<10;index++)
        {
        copyData[index] = data[index];
        }
    second = (Object*)copyData;
    assert(second->slotCount() == firstObject->slotCount());
    assert(second->type() == firstObject->type());
    assert(second->generation() == firstObject->generation());
    assert(second->isForwarded() == firstObject->isForwarded());
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
