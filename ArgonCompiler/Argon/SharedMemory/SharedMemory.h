//
//  SharedMemory.h
//  ArgonInspector
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef SharedMemory_h
#define SharedMemory_h

typedef unsigned long long Word;
typedef void* Pointer;
typedef Word* WordPointer;

typedef struct _Space
    {
    void* baseAddress;
    void* offsetAddress;
    void* maximumAddress;
    Word capacity;
    void* stackTop;
    } Space;

typedef struct _RootHolder
    {
    void* address;
    int source;
    void* sourceAddress;
    int sourceNumber;
    } RootHolder;

typedef struct _DataSegment
    {
    Word capacity;
    Word nextOffset;
    void* bytes;
    } DataSegment;

typedef struct _RootArray
    {
    int capacity;
    int currentIndex;
    int maximumIndex;
    RootHolder* roots;
    } RootArray;

//
// Working with Tags
//
_Bool isTaggedPointer(void* pointer);
_Bool isTaggedHandler(void* pointer);
void* _Nonnull taggedHandler(void* pointer);
_Bool isTaggedWord(Word word);
void* _Nonnull untaggedPointer(void* pointer);
Word untaggedWord(Word word);
Word untaggedInteger(Word value);
Word taggedInteger(Word value);
float untaggedFloat(Word value);
Word taggedFloat(float value);
unsigned char untaggedByte(Word value);
Word taggedByte(unsigned char value);
Word untaggedDate(Word value);
Word taggedDate(Word value);
_Bool untaggedBoolean(Word value);
Word taggedBoolean(_Bool value);
Word tagOfWord(Word);
Word tagOfPointer(void* pointer);
int wordTag(Word word);
void* _Nonnull taggedInstancePointer(void* value);
void* _Nonnull taggedClosurePointer(void* pointer);
void* _Nonnull taggedVectorPointer(void* pointer);
void* _Nonnull taggedBlockPointer(void* pointer);
void* _Nonnull taggedCodeBlockPointer(void* pointer);
void* _Nonnull taggedMethodPointer(void* pointer);
void* _Nonnull taggedMapPointer(void* pointer);
void* _Nonnull taggedDatePointer(void* pointer);
void* _Nonnull taggedStringPointer(void* pointer);
void* _Nonnull taggedSymbolPointer(void* pointer);
void* _Nonnull taggedTraitsPointer(void* pointer);
void* _Nonnull taggedHandlerPointer(void* pointer);
void* _Nonnull pointerTaggedWithTag(void* pointer,Word tag);
//
// Data Segment functions
//
void setWordAtPointer(Word word,void* pointer);
Word wordAtPointer(void* address);
void setPointerAtPointer(void *,void* address);
void setWordAtOffsetInDataSegment(Word word,int offset,void* segment);
void* _Nonnull pointerAtPointer(void* address);
void* _Nonnull allocateDataSegmentWithCapacity(int capacity);
void freeDataSegment(void* segment);
void* _Nonnull addressOfNextFreeWordsOfSizeInDataSegment(int size,void* segment);
//
// Spaces
void copySpaceOfSizeToPointer(Space* space,int size,void* pointer);
Word spaceUsedInSpace(Space* space);
void freeSpace(void* aSpace);
_Bool pointerInSpace(void* pointer,Space* space);
//
// Objects
//
int slotCountOfInstance(void* instance);
int generationCountOfInstance(void* instance);
int typeOfInstance(void* instance);
Word signedAsUnsignedPreservingBits(long word);
long unsignedAsSignedPreservingBits(Word word);
void* _Nonnull markPointerAsParentNode(void* pointer);
void* _Nonnull markPointerAsChildNode(void* pointer);
Word markWordAsNodeCount(Word count);
_Bool isMarkedAsParent(void* pointer);
_Bool isMarkedAsChild(void* pointer);
_Bool isMarkedAsCount(Word word);
Word clearWordNodeMarks(Word word);
void* _Nonnull clearPointerNodeMarks(void* pointer);
void setUntaggedPointerAtIndexAtPointer(void* writtenPointer,int index,void* pointer);
void* _Nonnull untaggedPointerAtIndexAtPointer(int index,void* pointer);
void copyBytes(void* destinationPointer,int destinationOffset,void* sourcePointer,int sourceOffset,int count);
//
// Allocation
void* allocateInstance(Space* space,int slotCount,int type);
_Nonnull Space* allocateSpaceWithCapacity(int capacity);
//
// Pointer logic
//
void setPointerAtIndexAtPointer(void* writtenPointer,int index,void* pointer);
void* _Nonnull pointerAtIndexAtPointer(int index,void* pointer);
void* _Nonnull decrementPointerBy(void* pointer,int size);
void* _Nonnull incrementPointerBy(void* pointer,int size);
void* _Nonnull incrementPointerByIndex(void* pointer,int indexOfWord);
_Bool isPointerNil(void* pointer);
void setWordAtIndexAtPointer(Word word,int index,void* pointer);
Word wordAtIndexAtPointer(int index,void* pointer);
void setFloatAtIndexAtPointer(float aFloat,int index,void* pointer);
float floatAtIndexAtPointer(int index,void* pointer);
void* pointerFromIndexAtPointer(int index,void* pointer);
Word distanceBetweenPointers(void *pointer1,void* pointer2);
Word pointerAsWord(void* pointer);
void* _Nonnull wordAsPointer(Word value);
Word* _Nonnull wordAsWordPointer(Word value);
Word* _Nonnull wordAsUntaggedWordPointer(Word value);
//
// Garbage collection
//
void copyRootsFromTo(void* arrayBase,Space* fromSpace,Space* toSpace);
static inline void* copyRoot(void* root,void** freePointer);
//
// Working with Root Arrays
//
_Nonnull void* allocateRootArray();
RootHolder* _Nonnull rootAtIndexInArray(void* rootArray,int index);
void addRootToRootArray(void* root,void* rootArray);
int rootArrayCount(void* rootArray);
int addRootFromSourceToRootArray(void* root,int source,void* sourcePointer,int sourceNumber,void* array);
void growRootArray(RootArray* array);
int addDataContentsToRootArray(void* theSegment,void* rootArray);
void updateRootSources(void* registers,Space* space,void* dataSegment,void* array);
void freeRootArray(void* array);
//
// Shared memory
//
int sharedMemoryOpen(const char* name);

#endif /* SharedMemory_h */
