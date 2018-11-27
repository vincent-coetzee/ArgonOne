//
//  Monitor.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "Monitor.hpp"

Monitor::Monitor()
    {
    pthread_mutex_init(&mutex,NULL);
    pthread_cond_init(&condition,NULL);
    }

Monitor::~Monitor()
    {
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&condition);
    }

void Monitor::unlock()
    {
    pthread_mutex_unlock(&mutex);
    }

void Monitor::lock()
    {
    pthread_mutex_lock(&mutex);
    pthread_cond_wait(&condition,&mutex);
    }

void Monitor::signal()
    {
    pthread_cond_signal(&condition);
    pthread_mutex_unlock(&mutex);
    }

void Monitor::broadcast()
    {
    pthread_cond_broadcast(&condition);
    pthread_mutex_unlock(&mutex);
    }

