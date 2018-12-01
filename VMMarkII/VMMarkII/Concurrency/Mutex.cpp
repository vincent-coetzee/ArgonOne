//
//  Mutex.cpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/11/30.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include "Mutex.hpp"

Mutex::Mutex(bool isRecursive)
    {
    if (isRecursive)
        {
        pthread_mutexattr_t Attr;
        pthread_mutexattr_init(&Attr);
        pthread_mutexattr_settype(&Attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&mutex, &Attr);
        }
    else
        {
        pthread_mutex_init(&mutex, NULL);
        }
    };

Mutex::~Mutex()
    {
    pthread_mutex_destroy(&mutex);
    }

void Mutex::lock()
    {
    pthread_mutex_lock(&mutex);
    }

void Mutex::unlock()
    {
    pthread_mutex_unlock(&mutex);
    }


