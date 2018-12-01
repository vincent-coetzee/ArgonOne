//
//  VirtualMachineManager.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef VirtualMachineManager_hpp
#define VirtualMachineManager_hpp

#include <stdio.h>
#include "List.hpp"

class Thread;
class VirtualMachine;
class ObjectMemory;

class VirtualMachineManager
    {
    public:
        VirtualMachineManager();
        ~VirtualMachineManager();
    private:
        ObjectMemory* objectMemory;
        List<Thread> threads = List<Thread>();
    };
#endif /* VirtualMachineManager_hpp */
