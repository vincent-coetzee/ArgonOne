//
//  Thread.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "Thread.hpp"
#include "VirtualMachine.hpp"
#include "ObjectMemory.hpp"

Thread::Thread(ObjectMemory* memory)
    {
    virtualMachine = new VirtualMachine(memory);
    }

Thread::~Thread()
    {
    }

void Thread::run()
    {
    std::cout << "Executing thread " << nativeThread << " in run loop";
    }
