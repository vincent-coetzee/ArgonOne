//
//  Monitor.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef Monitor_hpp
#define Monitor_hpp

#include <stdio.h>
#include <pthread.h>

class Monitor
    {
    public:
        Monitor();
        ~Monitor();
        void lock();
        void wait();
        void signal();
        void broadcast();
        void unlock();
    private:
        pthread_mutex_t mutex;
        pthread_cond_t condition;
    };
#endif /* Monitor_hpp */
