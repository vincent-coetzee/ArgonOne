//
//  ArgonPointers.h
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/27.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ArgonPointers_h
#define ArgonPointers_h

//
// Tagging and untagging pointers
//
#define untaggedPointer(p) ((Pointer)((((Word)p) & ~kBitsMask)))
#define taggedHandlerPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsHandler))
#define taggedObjectPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsObject))
#define taggedBoolean(b) (kBitsBoolean | b)
#define taggedByte(b) (kBitsByte | b)
#define taggedFloat(f) (kBitsFloat | f)
#define taggedInteger(i) (kBitsInteger | i)
#define taggedDate(d) (kBitsDate | d)
#define untaggedByte(b) ((unsigned char)value & 255)
#define untaggedBoolean(b) (b & 1)
#define untaggedDate(d) (d & ~kBitsMask)
#define untaggedFloat(f) (f & ~kBitsFloat)
#define untaggedInteger(i) (i & ~kBitsMask)
#define isTaggedObjectPointer(p) ((((Word)p) & kBitsObject) != 0)
#define isTaggedObjectWord(w) ((w & kBitsObject) != 0)
#define tagOfPointer(p) ((((Word)p) & kBitsMask) >> kBitsShift)
#define pointerTaggedWithTag(p,t) (((Word)p) | ((t & kBitsMask) << kBitsShift))
//
// Accessing words and pointers from
// pointers.
//
#define wordAtIndexAtPointer(index,pointer) (*(((WordPointer)untaggedPointer(pointer)) + index))
#define pointerAtIndexAtPointer(index,pointer) (*((Pointer*)(((WordPointer)untaggedPointer(pointer)) + index)))
#define setWordAtIndexAtPointer(word,index,pointer) *(((WordPointer)untaggedPointer(pointer))+index) = word
#define setPointerAtIndexAtPointer(newPointer,index,pointer) *((Pointer*)(((WordPointer)untaggedPointer(pointer))+index)) = newPointer
#define wordAtPointer(p) (*((WordPointer)untaggedPointer(p)))
#define pointerAtPointer(p) (*((Pointer*)untaggedPointer(p)))
#define setWordAtPointer(w,p) *((WordPointer)untaggedPointer(p)) = w
#define setPointerAtPointer(sp,p) *((Pointer*)untaggedPointer(p)) = sp
//
// Adjusting Pointers
//
#define pointerByAddingBytesToPointer(b,p) ((Pointer)(((char*)p)+b))
#define pointerByAddingWordsToPointer(w,p) ((Pointer)(((WordPointer)p)+w))
#define pointerByAddingLong(p,l)  ((Pointer)(((char*)p) + l))
//
// Some miscellaneous macros not really related to Pointers but
// which sort of belong here
//
#define clampedLong56(l) (((Word)l) & ((Word)72057594037927935))
#define clampedWord56(l) (((Word)l) & ((Word)72057594037927935))

#endif /* ArgonPointers_h */
