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
#define taggedPointer(p,t) ((Pointer)((((Word)p) & ~kBitsMask) | t))
#define taggedStringPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsString))
#define taggedSymbolPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsSymbol))
#define taggedTraitsPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsTraits))
#define tagggedDatePointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsDate))
#define taggedMapPointer(p) (void*)((((Word)p) & ~kBitsMask) | kBitsMap)
#define taggedHandlerPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsHandler))
#define taggedMethodPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsMethod))
#define taggedCodeBlockPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsCodeBlock))
#define taggedExtensionBlockPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsExtensionBlock))
#define taggedVectorPointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsVector))
#define taggedClosurePointer(p) ((void*)((((Word)p) & ~kBitsMask) | kBitsClosure))
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

#endif /* ArgonPointers_h */
