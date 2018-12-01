//
//  VirtualMachine.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "VirtualMachine.hpp"
#include "Thread.hpp"
#include <pthread.h>
#include "ObjectMemory.hpp"
#include "RootArray.hpp"

//
// Working with the thread stacks
//
#define pushWord(w) (*(this->SP--) = w)
#define pushPointer(p) (*((Pointer*)this->SP--) = p)
#define popWord() (*(this->SP++))
#define popPointer() (*((Pointer*)this->SP++))

VirtualMachine::VirtualMachine(ObjectMemory* memory)
    {
    objectMemory = memory;
    initMemory();
    }

void VirtualMachine::initMemory()
    {
    localBlock = malloc(kInitialThreadMemorySizeInBytes);
    ST = (WordPointer)pointerByAddingBytesToPointer(kInitialThreadMemorySizeInBytes - kWordSize,localBlock);
    SP = ST;
    IP = 0;
    BP = 0;
    conditions = 0;
    memset(generalRegisters,sizeof(Word)*kGeneralPurposeRegisterCount,0);
    memset(floatingPointRegisters,sizeof(Word)*kGeneralPurposeRegisterCount,0);
    }

VirtualMachine::~VirtualMachine()
    {
    free(localBlock);
    }

void VirtualMachine::addAllRootsToRootArray(RootArray* rootArray)
    {
    }

void* mainThreadLoop(void* parameters)
    {
    Thread* thread = (Thread*)parameters;
    thread->run();
    delete thread;
    return(NULL);
    }

Thread* VirtualMachine::createThread()
    {
    pthread_t* nativeThread = new pthread_t;
    Thread* thread = new Thread(this->objectMemory);
    pthread_create(nativeThread,NULL,mainThreadLoop,(void*)thread);
    thread->nativeThread = nativeThread;
    return(thread);
    }
