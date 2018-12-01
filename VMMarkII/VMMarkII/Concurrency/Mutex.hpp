//
//  Mutex.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef Mutex_hpp
#define Mutex_hpp

#include <stdio.h>
#include <pthread.h>

class Mutex
    {
    public:
        Mutex(bool isRecursiveå);
        ~Mutex();
        void lock();
        void unlock();
    private:
        pthread_mutex_t mutex;
    };

#endif /* Mutex_hpp */
