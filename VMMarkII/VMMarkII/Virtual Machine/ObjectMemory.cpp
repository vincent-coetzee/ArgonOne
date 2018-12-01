//
//  ArgonMemory.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "ObjectMemory.hpp"
#include "Object.hpp"
#include <string.h>
#include "ExtensionBlockPointerWrapper.hpp"
#include "StringPointerWrapper.hpp"
#include "VectorPointerWrapper.hpp"
#include "CobaltPointers.hpp"
#include "MapPointerWrapper.hpp"
#include "AssociationVectorPointerWrapper.hpp"
#include "String.hpp"
#include "MachineInstruction.hpp"
#include "Monitor.hpp"
#include "CobaltTypes.hpp"
#include "MachineInstruction.hpp"
#include "Mutex.hpp"
#include "RootArray.hpp"

#define isValidType(p) (((Object*)p)->type() >= 0 || ((Object*)p)->type() <= kMaximumType)

ObjectMemory* ObjectMemory::shared = new ObjectMemory(1024*1024*10);

Pointer ObjectMemory::allocateObject(int slotCount,int type,int flags,Pointer traits)
    {
    mutex->lock();
    long totalWords = kObjectBaseSizeInWords + slotCount + 1;
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(totalWords);
    Object* object = (Object*)pointer;
    object->setSlotCount(totalWords);
    object->setFlags(flags);
    object->setGeneration(1);
    object->setIsForwarded(false);
    object->setType(type);
    object->traits = traits;
    object->setIsHeader(true);
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    }

Pointer ObjectMemory::allocateExtensionBlockWithCapacityInWords(long capacity)
    {
    mutex->lock();
    long totalWords = capacity + kExtensionBlockFixedSlotCount;
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(totalWords);
    ObjectPointerWrapper wrapper = ObjectPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(totalWords);
    wrapper.setType(kTypeExtensionBlock);
    wrapper.setIsForwarded(false);
    wrapper.setIsHeader(true);
    setWordAtIndexAtPointer(capacity/kWordSize,kExtensionBlockCapacityIndex,pointer);
    setWordAtIndexAtPointer(0,kExtensionBlockCountIndex,pointer);
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    }

ObjectMemory::ObjectMemory(long capacity)
    {
    this->fromSpace = new MemorySpace(capacity);
    this->toSpace = new MemorySpace(capacity);
    this->finalSpace = new MemorySpace(capacity / 3);
    this->mutex = new Mutex(true);
    }

ObjectMemory::~ObjectMemory()
    {
    delete this->fromSpace;
    delete this->toSpace;
    delete this->finalSpace;
    delete this->mutex;
    }

Pointer ObjectMemory::allocateString(char const* string)
    {
    mutex->lock();
    long totalWords = kStringFixedSlotCount;
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(totalWords);
    StringPointerWrapper wrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(totalWords);
    wrapper.setType(kTypeString);
    wrapper.setIsForwarded(false);
    wrapper.setString(string);
    wrapper.setIsHeader(true);
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    }

Pointer ObjectMemory::allocateString(String string)
    {
    return(this->allocateString(string.characters()));
    }

Pointer ObjectMemory::allocateVectorWithCapacityInWords(long capacityInWords)
    {
    mutex->lock();
    long storageCapacity = capacityInWords * 3 / 2;
    long totalWords = kVectorFixedSlotCount;
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(totalWords);
    VectorPointerWrapper wrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(totalWords);
    wrapper.setType(kTypeVector);
    wrapper.setIsForwarded(false);
    wrapper.setCount(0);
    wrapper.setCapacity(storageCapacity);
    wrapper.setIsHeader(true);
    wrapper.setExtensionsBlockPointer(this->allocateExtensionBlockWithCapacityInWords(storageCapacity));
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    }
    
Pointer ObjectMemory::allocateMap()
    {
    mutex->lock();
    long storageCapacity = kMapFixedSlotCount + kMapNumberOfHashbuckets;
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(storageCapacity);
    printf("Allocated map at 0x%010lX\n",(unsigned long)pointer);
    MapPointerWrapper wrapper = MapPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(storageCapacity);
    wrapper.setType(kTypeMap);
    wrapper.setIsForwarded(false);
    printf("Allocated type %d with slot count of %ld\n",kTypeMap,storageCapacity);
    wrapper.setCount(0);
    wrapper.setCapacity(storageCapacity);
    wrapper.setIsHeader(true);
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    }

Pointer ObjectMemory::allocateAssociationVectorOfSizeInWords(long wordCount)
    {
    mutex->lock();
    long storageCapacity = kAssociationVectorFixedSlotCount + (wordCount*2);
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(storageCapacity);
    printf("Allocated association vector at 0x%lX\n",(unsigned long)pointer);
    AssociationVectorPointerWrapper wrapper = AssociationVectorPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(storageCapacity);
    wrapper.setType(kTypeAssociationVector);
    wrapper.setIsForwarded(false);
    wrapper.setCount(0);
    wrapper.setCapacity(wordCount);
    wrapper.setIsHeader(true);
    printf("Allocated type %d with slot count of %ld\n",kTypeAssociationVector,wordCount);
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    }

Pointer ObjectMemory::allocateTraits(String name,Pointer* parents,long parentsCount,SlotLayout* slots,long slotsCount)
    {
    return(this->allocateTraits(name.characters(),parents,parentsCount,slots,slotsCount));
    }

Pointer ObjectMemory::allocateTraits(char const* name,Pointer* parents,long parentsCount,SlotLayout* slots,long slotsCount)
    {
    mutex->lock();
    long wordCount = kTraitsFixedSlotCount + parentsCount + slotsCount * kSlotsPerSlotLayout;
    Pointer pointer = toSpace->allocateBlockWithSizeInWords(wordCount);
    printf("Allocated traits named %s at 0x%lX\n",name,(unsigned long)pointer);
    TraitsPointerWrapper wrapper = TraitsPointerWrapper(pointer);
    wrapper.setGeneration(1);
    wrapper.setSlotCount(wordCount);
    wrapper.setIsHeader(true);
    wrapper.setType(kTypeTraits);
    printf("Allocated type %d with slot count of %ld\n",kTypeTraits,wordCount);
    wrapper.setIsForwarded(false);
    Pointer namePointer = this->allocateString(name);
    setWordAtIndexAtPointer(parentsCount,kTraitsParentsCountIndex,pointer);
    setWordAtIndexAtPointer(slotsCount,kTraitsSlotLayoutsCountIndex,pointer);
    setPointerAtIndexAtPointer(namePointer,kTraitsNameIndex,pointer);
    WordPointer index = ((WordPointer)pointer) + kTraitsFixedSlotCount;
    for (int loop=0;loop<slotsCount;loop++)
        {
        SlotLayout* layout = (SlotLayout*)index;
        layout->namePointer = slots->namePointer;
        layout->traitsPointer = slots->traitsPointer;
        layout->offsetAndFlags = slots->offsetAndFlags;
        slots++;
        index += kSlotsPerSlotLayout;
        }
    for (int loop=0;loop<parentsCount;loop++)
        {
        Pointer* parentPointer = (Pointer*)index++;
        *parentPointer = parents++;
        }
    mutex->unlock();
    return(taggedObjectPointer(pointer));
    };

void ObjectMemory::copySpaceToSpace(MemorySpace* fromSpace,MemorySpace* toSpace)
    {
    toSpace->basePointer = fromSpace->basePointer;
    toSpace->nextPointer = fromSpace->nextPointer;
    toSpace->memoryTop = fromSpace->memoryTop;
    }

Pointer ObjectMemory::copyRoot(Pointer outerRoot,Pointer* freePointer)
    {
    Word header;
    
    Pointer root = untaggedPointer(outerRoot);
    printf("Copying a root at 0x%ld\n",(long)root);
    Object* objectPointer = (Object*)root;
    printf(objectPointer->isHeader() ? "Is header\n" : "Not header\n");
    header = objectPointer->header;
    printf("Scanning object at 0x%lX \nHeader below\n",(unsigned long)objectPointer);
    std::cout << MachineInstruction::bitStringFor(header) << "\n";
    printf("Object is type %ld slot count %ld\n",objectPointer->type(),objectPointer->slotCount());
    if (objectPointer->isForwarded())
        {
//        printf("FOUND FORWARDED\n");
        return(*((Pointer*)(pointerByAddingLong(root,kWordSize))));
        }
    objectPointer->setGeneration(objectPointer->generation());
    printf("Object slot count %ld \n",objectPointer->slotCount());
    long totalBytes = objectPointer->slotCount() * kWordSize;
    WordPointer newRoot = *((WordPointer*)freePointer);
    *freePointer = pointerByAddingLong(*freePointer,totalBytes);
    memcpy(newRoot,root,totalBytes);
    printf("Copied %ld bytes from 0x%lX to 0x%lX\n",totalBytes,(unsigned long)root,(unsigned long)newRoot);
    objectPointer->setIsForwarded(true);
    objectPointer->traits = newRoot;
    *((Pointer*)(pointerByAddingLong(root,kWordSize))) = newRoot;
    return(newRoot);
    }

void ObjectMemory::copyRootsFromTo(RootArray* rootArray,MemorySpace* fromSpace,MemorySpace* toSpace)
    {
    Pointer unscannedPointer;
    Pointer freePointer;
    
    MemorySpace temp = *toSpace;
    copySpaceToSpace(fromSpace,toSpace);
    copySpaceToSpace(&temp,fromSpace);
    unscannedPointer = freePointer = toSpace->basePointer;
    long rootCount = rootArray->count;
    for (long index=0;index<rootCount;index++)
        {
        rootArray->elements[index].address = this->copyRoot(rootArray->elements[index].address,&freePointer);
        }
    while (unscannedPointer < freePointer)
        {
        Object* object = (Object*)unscannedPointer;
        printf(object->isHeader() ? "Is header\n" : "Not header\n");
        printf("Scanning 0x%lX \n",(unsigned long)object);
        long slotCount = object->slotCount();
        printf("Object has %ld slots and type of %ld\n",slotCount,object->type());
        printf("UnscannedPointer before addition is 0x%lX\n",(unsigned long)unscannedPointer);
        Pointer innerPointer = unscannedPointer;
        unscannedPointer = pointerByAddingLong(unscannedPointer,slotCount*kWordSize);
        innerPointer = pointerByAddingLong(innerPointer,kWordSize);
        printf("UnscannedPointer after addition is 0x%lX\n",(unsigned long)unscannedPointer);
        printf("innerPointer is 0x%lX\n",(unsigned long)innerPointer);
        for (int index=1;index<slotCount;index++)
            {
            Pointer innerWord = *((Pointer*)innerPointer);
            if (isTaggedPointer(innerWord) && fromSpace->memoryTop > untaggedPointer(innerWord))
                {
                unsigned long tag = tagOfPointer(innerWord);
                printf("Found tagged pointer at %08lX following pointer\n",(unsigned long)innerWord);
                *((Pointer*)innerPointer) = (void*)pointerTaggedWithTag(copyRoot((char*)innerWord,&freePointer),tag);
                }
            else
                {
                printf("Ignoring 0x%lX as pointer\n",(unsigned long)innerWord);
                }
            innerPointer = pointerByAddingLong(innerPointer,kWordSize);
            }
        }
    }
void ObjectMemory::collectGarbage(RootArray* rootArray)
    {
    mutex->lock();
    copyRootsFromTo(rootArray,fromSpace,toSpace);
    mutex->unlock();
    }

void ObjectMemory::dumpBusyWords()
    {
    long numberOfWords = (((char*)toSpace->nextPointer) - ((char*)toSpace->basePointer)) / kWordSize;
    ObjectMemory::dumpWordsAtPointerForLength(toSpace->basePointer,numberOfWords);
    }

void ObjectMemory::dumpWordsAtPointerForLength(Pointer pointer,long length)
    {
    printf("\n");
    for (long index=0;index<length;index++)
        {
        Word theWord = wordAtIndexAtPointer(index,pointer);
        String bitString = MachineInstruction::bitStringFor(theWord);
        Object objectPointer = Object(theWord);
        if (objectPointer.isHeader())
            {
            bool excluded = false;
            if (isTaggedWord(theWord) && spaceContainsPointer(toSpace,(Pointer)theWord) && isValidType((Pointer)theWord))
                {
                excluded = true;
                }
            printf("0x%8lX %s Type %02ld SlotCount:%04ld %s\n",(((unsigned long)pointer)+index*kWordSize),bitString.characters(),objectPointer.type(),objectPointer.slotCount(),(isTaggedWord(theWord) ? (excluded ? "Excluded" : "Tagged") : ""));
            }
        else
            {
            printf("0x%8lX %s %s\n",(((unsigned long)pointer)+index*kWordSize),bitString.characters(),(isTaggedWord(theWord) ? "Tagged" : ""));
            }
        }
    }
