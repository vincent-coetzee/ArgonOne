//
//  VirtualMachineManager.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "VirtualMachineManager.hpp"
#include "ObjectMemory.hpp"
#include "Thread.hpp"
#include "VirtualMachine.hpp"

#define kDefaultObjectMemoryCapacityInBytes (20*1024*1024)

VirtualMachineManager::VirtualMachineManager()
    {
    objectMemory = new ObjectMemory(kDefaultObjectMemoryCapacityInBytes);
    }
