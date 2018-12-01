//
//  ScopedMutex.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "ScopedMutex.hpp"

ScopedMutex::ScopedMutex()
    {
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    };

ScopedMutex::~ScopedMutex()
    {
    pthread_mutex_unlock(&mutex);
    pthread_mutex_destroy(&mutex);
    }

void ScopedMutex::lock()
    {
    pthread_mutex_lock(&mutex);
    }

void ScopedMutex::unlock()
    {
    pthread_mutex_unlock(&mutex);
    }
