//
//  ScopedMutex.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef ScopedMutex_hpp
#define ScopedMutex_hpp

#include <stdio.h>
#include <pthread.h>

class ScopedMutex
    {
    public:
        ScopedMutex();
        ~ScopedMutex();
        void lock();
        void unlock();
    private:
        pthread_mutex_t mutex;
    };
    
#endif /* ScopedMutex_hpp */
