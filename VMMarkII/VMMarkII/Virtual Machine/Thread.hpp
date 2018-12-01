//
//  Thread.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef Thread_hpp
#define Thread_hpp

#include <stdio.h>
#include <pthread.h>

class VirtualMachine;
class ObjectMemory;

class Thread
    {
    public:
        Thread(ObjectMemory* memory);
        ~Thread();
        void run();
    public:
        friend class VirtualMachine;
    private:
        pthread_t* nativeThread;
        VirtualMachine* virtualMachine;
    };
#endif /* Thread_hpp */
