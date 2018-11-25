//
//  SharedMemory.c
//  ArgonInspector
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#import "SharedMemory.h"

int sharedMemoryOpen(const char* name)
    {
    return(shm_open(name, O_RDWR | O_CREAT , 0700));
    }

#define kWordSize (8)

#define kTagInstance (((Word)4) << ((Word)59))
#define kTagForwarded (((Word)1) << ((Word)58))
#define kTagSlotCount (((Word)65535) << ((Word)32))
#define kTagGeneration (((Word)255) << ((Word)24))
#define kTagType (((Word)255) << ((Word)8))

#define kSourceStack (1)
#define kSourceData (2)
#define kSourceRegister (3)
#define kSourceGlobal (4)

#define kGeneralPurposeRegisterCount (32)

#define kBitsMask (((Word)15) << ((Word)59))
#define kBitsInteger (((Word)0) << ((Word)59))
#define kBitsFloat (((Word)1) << ((Word)59))
#define kBitsByte (((Word)2) << ((Word)59))
#define kBitsBoolean (((Word)3) << ((Word)59))
#define kBitsInstance (((Word)4) << ((Word)59))
#define kBitsDate (((Word)5) << ((Word)59))
#define kBitsHandler (((Word)6) << ((Word)59))
#define kBitsVector (((Word)7) << ((Word)59))
#define kBitsMap (((Word)8) << ((Word)59))
#define kBitsCodeBlock (((Word)9) << ((Word)59))
#define kBitsBlock (((Word)10) << ((Word)59))
#define kBitsMethod (((Word)11) << ((Word)59))
#define kBitsClosure (((Word)12) << ((Word)59))
#define kBitsTraits (((Word)13) << ((Word)59))
#define kBitsString (((Word)14) << ((Word)59))
#define kBitsSymbol (((Word)15) << ((Word)59))

#define kBitsShift ((Word)59)
#define kForwardedShift ((Word)58)

#define kItemInteger ((Word)0)
#define kItemFloat ((Word)1)
#define kItemByte ((Word)2)
#define kItemBoolean ((Word)3)
#define kItemInstance ((Word)4)
#define kItemDate ((Word)5)
#define kItemHandler ((Word)6)
#define kItemVector ((Word)7)
#define kItemMap ((Word)8)
#define kItemCodeBlock ((Word)9)
#define kItemBlock ((Word)10)
#define kItemMethod ((Word)11)
#define kItemClosure ((Word)12)
#define kItemTraits ((Word)13)
#define kItemString ((Word)14)
#define kItemSymbol ((Word)15)

#define kModeMask  (((Word)3) << ((Word)48))
#define kModeShift  ((Word)48)
#define kFlagsMask  (((Word)31) << ((Word)43))
#define kFlagsShift  ((Word)43)
#define kTypeMask  (((Word)15) << ((Word)60))
#define kTypeShift  ((Word)60)
#define kOperationMask  (((Word)1023) << ((Word)50))
#define kOperationShift  ((Word)50)
#define kRegister1Mask  (((Word)255) << ((Word)35))
#define kRegister1Shift  ((Word)35)
#define kRegister2Mask  (((Word)255) << ((Word)27))
#define kRegister2Shift  ((Word)27)
#define kRegister3Mask  (((Word)255) << ((Word)19))
#define kRegister3Shift  ((Word)19)
#define kAddressMask  ((Word)536870911)
#define kAddressShift  ((Word)0)
#define kAddressSignMask  (((Word)1) << ((Word)29))
#define kAddressSignShift  ((Word)29)
#define kOffsetMask  (((Word)131071) << ((Word)0))
#define kOffsetShift  ((Word)0)
#define kOffsetSignMask  (((Word)1) << ((Word)18))
#define kOffsetSignShift  ((Word)18)
#define kConstantMask  (((Word)8796093022207) << ((Word)0))
#define kConstantShift  ((Word)0)
#define kConstantSignMask  (((Word)1) << ((Word)43))
#define kConstantSignShift  ((Word)43)

#define kMarkParent (((Word)1) << ((Word)61))
#define kMarkChild (((Word)2) << ((Word)61))
#define kMarkCount (((Word)3) << ((Word)61))
#define kMarkBottomMask (~(((Word)3) << ((Word)61)))

#define kMarkMask ((((Word)3) << ((Word)61)))

#define kFloatMask ((Word)4294967295)

#define kConditionE (128)
#define kConditionEShift = ((Word)7)
#define kConditionGTE (64)
#define kConditionGTEShift = ((Word)6)
#define kConditionGT (32)
#define kConditionGTShift = ((Word)5)
#define kConditionLTE (16)
#define kConditionLTEShift = ((Word)4)
#define kConditionLT (8)
#define kConditionLTShift = ((Word)3)
#define kConditionZ (4)
#define kConditionZShift = ((Word)2)

#define kBP 1
#define kSP 2
#define kIP 3
#define kST 4
#define kLP 5
#define kGP0 6
#define kThreadRegisterCount (37)

#define kInitialTaggedPointerListCount (20000)

#define _WordAsPointer(w) (((void*)w))
#define _PointerAsWord(p) (((Word)p))

#define kThreadIndexInvalid (-1)
#define kSourceIndexInvalid (-1)
#define kSourceThreadStack (1)
#define kSourceData (2)
#define kSourceThreadRegister (3)
#define kSourceGlobal (4)

void copySpaceToSpace(Space* toSpace,Space* fromSpace);
int pointerTag(void* pointer,Word* word);

//
// Working with TAGS
//
Word untaggedInteger(Word value)
    {
    return(value & ~kBitsMask);
    }

int pointerTag(void* pointer,Word* wordPointer)
    {
    Word word = (Word)pointer;
    *wordPointer = ((Word)pointer) & ~kBitsMask;
    return((word & kBitsMask) >> kBitsShift);
    }

int wordTag(Word word)
    {
    return((word & kBitsMask) >> kBitsShift);
    }

Word untaggedWord(Word word)
    {
    return((word & ~kBitsMask));
    }

Word untaggedDate(Word value)
    {
    return(value & ~kBitsMask);
    }

Word taggedDate(Word value)
    {
    return(value | kBitsDate);
    }

float untaggedFloat(Word value)
    {
    Word aValue = value;
    float* floatPointer = (float *)&aValue;
    aValue = aValue & ~kBitsMask;
    return(*floatPointer);
    }

Word taggedFloat(float value)
    {
    float aValue = value;
    WordPointer wordPointer = (WordPointer)&aValue;
    *wordPointer = (*wordPointer & ~kBitsMask) | kBitsFloat;
    return(*wordPointer);
    }

_Bool isMarkedAsParent(void* pointer)
    {
    Word word = ((Word)pointer);
    return((word & kMarkParent) == kMarkParent);
    }

_Bool isMarkedAsChild(void* pointer)
    {
    Word word = ((Word)pointer);
    return((word & kMarkChild) == kMarkChild);
    }

_Bool isMarkedAsCount(Word word)
    {
    return((word & kMarkCount) == kMarkCount);
    }

void* _Nonnull markPointerAsParentNode(void* pointer)
    {
    Word word = ((Word)pointer);
    word &= kMarkBottomMask;
    word |= kMarkParent;
    return(((void*)word));
    }
void* _Nonnull markPointerAsChildNode(void* pointer)
    {
    Word word = ((Word)pointer);
    word &= kMarkBottomMask;
    word |= kMarkChild;
    return(((void*)word));
    }

Word markWordAsNodeCount(Word word)
    {
    word &= kMarkBottomMask;
    return(word | kMarkCount);
    }

Word clearWordNodeMarks(Word word)
    {
    return(word & ~kMarkMask);
    }

void* _Nonnull clearPointerNodeMarks(void* pointer)
    {
    Word word = ((Word)pointer);
    word &= ~kMarkMask;
    return(((void*)word));
    }

Word taggedByte(unsigned char value)
    {
    return(kBitsByte | value);
    }

Word taggedBoolean(_Bool value)
    {
    return(kBitsBoolean | value);
    }

unsigned char untaggedByte(Word value)
    {
    return(((unsigned char)value & 255));
    }

_Bool untaggedBoolean(Word value)
    {
    return(value & 1);
    }

void* _Nonnull taggedInstancePointer(void* value)
    {
    return((void*)((((Word)value) & ~kBitsMask) | kBitsInstance));
    }

void* _Nonnull taggedClosurePointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsClosure));
    }

void* _Nonnull taggedVectorPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsVector));
    }

void* _Nonnull taggedBlockPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsBlock));
    }

void* _Nonnull taggedCodeBlockPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsCodeBlock));
    }

void* _Nonnull taggedMethodPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsMethod));
    }

void* _Nonnull taggedHandlerPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsHandler));
    }

void* _Nonnull taggedMapPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsMap));
    }

void* _Nonnull taggedDatePointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsDate));
    }

void* _Nonnull taggedStringPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsString));
    }

void* _Nonnull taggedSymbolPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsSymbol));
    }

void* _Nonnull taggedTraitsPointer(void* pointer)
    {
    return((void*)((((Word)pointer) & ~kBitsMask) | kBitsTraits));
    }

Word pointerAsWord(void* pointer)
    {
    return(((Word)pointer));
    }

Word distanceBetweenPointers(void *pointer1,void* pointer2)
    {
    if (pointer1 > pointer2)
        {
        return(pointer1 - pointer2);
        }
    else
        {
        return(pointer2 - pointer1);
        }
    }

void* pointerFromIndexAtPointer(int index,void* pointer)
    {
    return((void*)(pointer + index*8));
    }

void* wordAsPointer(Word value)
    {
    return((void*)value);
    }

Word* _Nonnull wordAsWordPointer(Word value)
    {
    return((Word*)value);
    }

Word* _Nonnull wordAsUntaggedWordPointer(Word value)
    {
    return((Word*)untaggedPointer((void*)value));
    }

Word tagOfWord(Word word)
    {
    return((kBitsMask & word) >> kBitsShift);
    }

Word tagOfPointer(void* pointer)
    {
    return((((Word)pointer) & kBitsMask) >> kBitsShift);
    }

void* _Nonnull pointerTaggedWithTag(void* pointer,Word tag)
    {
    return(((void*)(((Word)pointer) & tag)));
    }

Word signedAsUnsignedPreservingBits(long word)
    {
    return((Word)word);
    }
long unsignedAsSignedPreservingBits(Word word)
    {
    return((long)word);
    }

Space* allocateSpaceWithCapacity(int capacity)
    {
    Space* space = (Space*)malloc(sizeof(Space));
    space->baseAddress = malloc(capacity);
    space->capacity = capacity;
    space->offsetAddress = space->baseAddress;
    space->maximumAddress = space->baseAddress + space->capacity;
    space->stackTop = space->baseAddress + space->capacity - kWordSize;
    return(space);
    }

void setWordAtOffsetInDataSegment(Word word,int offset,void* segment)
    {
    DataSegment* dataSegment = (DataSegment*)segment;
    WordPointer pointer = dataSegment->bytes + (8*offset);
    *pointer = word;
    }

void* _Nonnull allocateDataSegmentWithCapacity(int capacity)
    {
    DataSegment* segment = (DataSegment*)malloc(sizeof(DataSegment));
    segment->capacity = capacity;
    segment->bytes = malloc(capacity);
    segment->nextOffset = 0;
    memset((void*)segment->bytes,0,capacity);
    return((void*)segment);
    }

void* addressOfNextFreeWordsOfSizeInDataSegment(int size,void* segment)
    {
    int adjustedSize = ((size / 8) + 1)*8;
    DataSegment* dataSegment = ((DataSegment*)segment);
    unsigned long offset = dataSegment->nextOffset;
    dataSegment->nextOffset += adjustedSize;
    Pointer pointer = (Pointer)(dataSegment->bytes + offset);
    return(pointer);
    }

void setWordAtPointer(Word word,void* pointer)
    {
    *((WordPointer)pointer) = word;
    }

Word wordAtPointer(void* address)
    {
    return(*((WordPointer)address));
    }

void setPointerAtPointer(void* pointer,void* address)
    {
    *((void**)address) = pointer;
    }

void* _Nonnull pointerAtPointer(void* address)
    {
    return(*((void**)address));
    }

void freeDataSegment(void* segment)
    {
    DataSegment* theSegment = ((DataSegment*)segment);
    free(theSegment->bytes);
    free(theSegment);
    }

void copyBytes(void* destinationPointer,int destinationOffset,void* sourcePointer,int sourceOffset,int count)
    {
    void* target = untaggedPointer(destinationPointer) + destinationOffset;
    void* source = untaggedPointer(sourcePointer) + sourceOffset;
    memcpy(target,source,count);
    }

void setFloatAtIndexAtPointer(float aFloat,int index,void* pointer)
    {
    WordPointer wordPointer = ((WordPointer)(pointer + index*kWordSize));
    float* floatPointer = (float*)wordPointer;
    *floatPointer = aFloat;
    }

float floatAtIndexAtPointer(int index,void* pointer)
    {
    WordPointer wordPointer = ((WordPointer)(pointer + index*kWordSize));
    float* floatPointer = (float*)wordPointer;
    return(*floatPointer);
    }

Word wordAtIndexAtPointer(int index,void* pointer)
    {
    Word* offset = ((Word*)(untaggedPointer(pointer) + index*kWordSize));
    return(*offset);
    }

void* pointerAtIndexAtPointer(int index,void* pointer)
    {
    void** offset = ((void**)(untaggedPointer(pointer) + index*kWordSize));
    return(*offset);
    }

void* _Nonnull untaggedPointerAtIndexAtPointer(int index,void* pointer)
    {
    void** offset = ((void**)(untaggedPointer(pointer) + index*kWordSize));
    return(*offset);
    }

void* _Nonnull decrementPointerBy(void* pointer,int size)
    {
    return(pointer - size);
    }

void* _Nonnull incrementPointerBy(void* pointer,int size)
    {
    return(pointer + size);
    }

void* _Nonnull incrementPointerByIndex(void* pointer,int indexOfWord)
    {
    return(pointer + indexOfWord*kWordSize);
    }

void* allocateInstance(Space* space,int slotCount,int type)
    {
    void* instanceAddress = space->offsetAddress;
    int totalBytes = slotCount*kWordSize;
    if (space->offsetAddress + totalBytes >= space->maximumAddress)
        {
        return(NULL);
        }
    space->offsetAddress += totalBytes;
    memset(instanceAddress,0,totalBytes);
    Word header = (((Word)slotCount)<<((Word)32)) | (((Word)type) << ((Word)8)) | (((Word)1) << ((Word)24));
    *((Word*)instanceAddress) = header;
    return(instanceAddress);
    }

void setWordAtIndexAtPointer(Word word,int index,void* pointer)
    {
    Word* newOffset = ((Word*)(untaggedPointer(pointer) + (index*kWordSize)));
    *newOffset = word;
    }

void setPointerAtIndexAtPointer(void* writtenPointer,int index,void* pointer)
    {
    void** newOffset = ((void**)(untaggedPointer(pointer) + (index*kWordSize)));
    *newOffset = writtenPointer;
    }

void setUntaggedPointerAtIndexAtPointer(void* writtenPointer,int index,void* pointer)
    {
    void** newOffset = ((void**)(pointer + (index*kWordSize)));
    *newOffset = writtenPointer;
    }

_Bool isTaggedPointer(void* pointer)
    {
    Word word = (Word)pointer;
    return(((word & kBitsMask) > kBitsDate));
    }

_Bool isTaggedHandler(void* pointer)
    {
    Word word = (Word)pointer;
    return((word & kBitsHandler) == kBitsHandler);
    }

void* _Nonnull taggedHandler(void* pointer)
    {
    Word word = (Word)pointer;
    word |= kBitsHandler;
    return((void*)word);
    }

_Bool isTaggedWord(Word word)
    {
    return(((word & kBitsMask) > kBitsDate));
    }
//
// Working with RootArrays
//
void* allocateRootArray()
    {
    RootArray* array = (RootArray*)malloc(sizeof(RootArray));
    array->capacity = kWordSize * 1024;
    array->currentIndex = 0;
    array->maximumIndex = 1023;
    int rootsSize = array->capacity * sizeof(RootHolder);
    array->roots = (RootHolder*)malloc(rootsSize);
    return((void*)array);
    }

void freeRootArray(void* array)
    {
    RootArray* rootArray = (RootArray*)array;
    free(rootArray->roots);
    free(rootArray);
    }

int addDataContentsToRootArray(void* theSegment,void* rootArray)
    {
    int count = 0;
    DataSegment* segment = (DataSegment*)theSegment;
    for (int index = 0;index<segment->nextOffset;index+=8)
        {
        void* address = *(Pointer*)segment->bytes;
        if (isTaggedPointer(address))
            {
            count++;
            addRootToRootArray(kSourceData,kThreadIndexInvalid,index,address,rootArray);
            }
        }
    return(count);
    }

long addRootToRootArray(long sourceIndex,long threadIndex,long itemIndex,void* root,void* rootArray)
    {
    RootArray* array = ((RootArray*)rootArray);
    if (array->currentIndex >= array->capacity - 1)
        {
        growRootArray(array);
        }
    RootHolder holder;
    holder.address = root;
    holder.sourceIndex = (int)sourceIndex;
    holder.threadIndex = (int)threadIndex;
    holder.itemIndex = (int)itemIndex;
    array->roots[array->currentIndex] = holder;
    long index = array->currentIndex;
    array->currentIndex++;
    return(index);
    }

void growRootArray(RootArray* array)
    {
    int newSize = (array->capacity * 3 / 2)*sizeof(RootHolder);
    RootHolder* newRoots = malloc(newSize);
    memcpy((void*)newRoots,array->roots,array->capacity*sizeof(RootHolder));
    free(array->roots);
    array->roots = newRoots;
    array->capacity = array->capacity * 3 / 2;
    }

RootHolder* _Nonnull rootAtIndexInArray(void* rootArray,int index)
    {
    RootArray* array = (RootArray*) rootArray;
    if (index <= array->currentIndex)
        {
        return(&array->roots[index]);
        }
    return((RootHolder*)1);
    }

int rootArrayCount(void* rootArray)
    {
    RootArray* array = (RootArray*) rootArray;
    return(array->currentIndex);
    }

char* bitStringFor(char* string,Word word)
    {
    Word bitPattern = (unsigned long)9223372036854775808UL;
    for (int index=0;index<64;index++)
        {
        *string++ = (word & bitPattern) == bitPattern ? '1': '0';
        if (index > 0 && (index % 8) == 0)
            {
            *string++ = ' ';
            }
        bitPattern >>= 1;
        }
    *string = 0;
    return(string);
    }

int slotCountOfInstance(void* instance)
    {
    Word header = *((Word*)instance);
    int slotCount = (header & kTagSlotCount) >> 32;
    return(slotCount);
    }

int generationCountOfInstance(void* instance)
    {
    Word header = *((Word*)instance);
    int generation = (header & kTagGeneration) >> 24;
    return(generation);
    }

int typeOfInstance(void* instance)
    {
    Word header = *((Word*)instance);
    int type = (header & kTagType) >> 8;
    return(type);
    }

unsigned long totalBytesCopied = 0;
unsigned long totalObjectsCopied = 0;


void copySpaceToSpace(Space* fromSpace,Space* toSpace)
    {
    toSpace->baseAddress = fromSpace->baseAddress;
    toSpace->offsetAddress = fromSpace->offsetAddress;
    toSpace->maximumAddress = fromSpace->maximumAddress;
    toSpace->capacity = fromSpace->capacity;
    toSpace->stackTop = fromSpace->stackTop;
    }

_Bool pointerInSpace(void* pointer,Space* space)
    {
    if ((pointer >= space->baseAddress) && (pointer < space->maximumAddress))
        {
        return(1);
        }
    return(0);
    }

void freeSpace(void* aSpace)
    {
    Space* space = ((Space*)aSpace);
    free(space->baseAddress);
    free(space);
    }

Word spaceUsedInSpace(Space* space)
    {
    return(space->offsetAddress - space->baseAddress);
    }

void* _Nonnull untaggedPointer(void* pointer)
    {
    void* localPointer = pointer;
    WordPointer wordPointer = (WordPointer)&localPointer;
    *wordPointer &= ~kBitsMask;
    return(localPointer);
    }

_Bool isPointerNil(void* pointer)
    {
    return(untaggedPointer(pointer) == NULL);
    }

void copySpaceOfSizeToPointer(Space* space,int size,void* pointer)
    {
    WordPointer wordPointer = ((WordPointer)pointer);
    *wordPointer++ = (Word)size;
    WordPointer fromPointer = (WordPointer)space->baseAddress;
    int offset = 0;
    while (offset < size - kWordSize)
        {
        *wordPointer++ = *fromPointer++;
        offset += kWordSize;
        }
    }

void copyRootsFromTo(Pointer arrayBase,Space* fromSpace,Space* toSpace)
    {
    Pointer unscannedPointer;
    Pointer freePointer;
    
    totalBytesCopied = 0;
    totalObjectsCopied = 0;
    Space temp = *toSpace;
    copySpaceToSpace(fromSpace,toSpace);
    copySpaceToSpace(&temp,fromSpace);
    unscannedPointer = freePointer = toSpace->baseAddress;
    RootArray* rootArray = (RootArray*)arrayBase;
    int rootCount = rootArray->currentIndex;
    for (int index=0;index<rootCount;index++)
        {
        rootArray->roots[index].address = copyRoot(rootArray->roots[index].address,&freePointer);
        }
    while (unscannedPointer < freePointer)
        {
        Word header = *((WordPointer)unscannedPointer);
        int slotCount = (header & kTagSlotCount) >> 32;
        Pointer innerPointer = unscannedPointer;
        unscannedPointer += slotCount*kWordSize;
        innerPointer += kWordSize;
        for (int index=1;index<slotCount;index++)
            {
            Pointer innerWord = *((Pointer*)innerPointer);
            if (isTaggedPointer(innerWord))
                {
                unsigned long tag = tagOfPointer(innerWord);
//                printf("FOUND TAGGED POINTER AT %08X\n",(unsigned int)innerWord);
                *((Pointer*)innerPointer) = pointerTaggedWithTag(copyRoot(innerWord,&freePointer),tag);
                }
            innerPointer += kWordSize;
            }
        }
    printf("COPIED %ld BYTES WITH %ld OBJECTS",totalBytesCopied,totalObjectsCopied);
    }

static inline void* copyRoot(void* outerRoot,void** freePointer)
    {
    Word header;
    int slotCount;
    
    void* root = untaggedPointer(outerRoot);
//    printf("COPYING OBJECT %ld\n",*((WordPointer)(root+16)));
    totalObjectsCopied++;
    header = *((Word*)root);
    char string[128];
    bitStringFor(string, header);
//    printf("HEADER FOR ROOT %08X IS %s\n",root,string);
    if ((header & kTagForwarded) == kTagForwarded)
        {
//        printf("FOUND FORWARDED\n");
        return(*((Pointer*)(root+kWordSize)));
        }
    int generation = (header & kTagGeneration) >> 24;
    generation++;
    header |= (((Word)generation) << ((Word)24));
    *((Word*)root) = header;
    slotCount = (header & kTagSlotCount) >> ((Word)32);
    int totalBytes = slotCount*kWordSize;
    void* newRoot = *freePointer;
    *freePointer = *freePointer + totalBytes;
    memcpy(newRoot,root,totalBytes);
    totalBytesCopied += totalBytes;
//    printf("COPIED %d BYTES FROM %08X TO %08X\n",totalBytes,(unsigned int)root,(unsigned int)newRoot);
    header |= kTagForwarded;
    *((WordPointer)root) = header;
    *((Pointer*)(root+8)) = newRoot;
    return(newRoot);
    }

