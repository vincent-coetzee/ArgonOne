//
//  VirtualMachine.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef VirtualMachine_hpp
#define VirtualMachine_hpp

#include <stdio.h>
#include "CobaltTypes.hpp"
#include "CobaltPointers.hpp"

#define kGeneralPurposeRegisterCount (32)
#define kFloatingPointRegisterCount (32)

#define kConditionZeroMask (((Word)1)<<((Word)59))
#define kConditionZeroShift (59)
#define kConditionNotZeroMask (((Word)1)<<((Word)58))
#define kConditionNotZeroShift (58)
#define kConditionEQMask (((Word)1)<<((Word)57))
#define kConditionEQShift (57)
#define kConditionNEQMask (((Word)1)<<((Word)56))
#define kConditionNEQShift (56)
#define kConditionGTEMask (((Word)1)<<((Word)55))
#define kConditionGTEShift (55)
#define kConditionGTMask (((Word)1)<<((Word)54))
#define kConditionGTShift (54)
#define kConditionLTMask (((Word)1)<<((Word)55))
#define kConditionLTShift (55)
#define kConditionLTEMask (((Word)1)<<((Word)54))
#define kConditionLTEShift (54)

#define kInitialThreadMemorySizeInBytes (2*1024*1024)

class Thread;
class ObjectMemory;
class RootArray;

class VirtualMachine
    {
    public:
        VirtualMachine(ObjectMemory* memory);
        ~VirtualMachine();
        void initMemory();
        void addAllRootsToRootArray(RootArray* rootArray);
        Thread* createThread();
        friend class Thread;
    private:
        long IP;
        Pointer codeContainer;
        WordPointer SP;
        WordPointer ST;
        Pointer BP;
        Word generalRegisters[kGeneralPurposeRegisterCount];
        Word floatingPointRegisters[kFloatingPointRegisterCount];
        Word conditions;
        ObjectMemory* objectMemory;
        Pointer localBlock;
    };
#endif /* VirtualMachine_hpp */
