//
//  List.hpp
//  VMMarkII
//
//  Created by Vincent Coetzee on 2018/12/01.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef List_hpp
#define List_hpp

#include <stdio.h>
#include <stdlib.h>

template <class T>

class List
    {
    public:
        List()
            {
            elementCapacity = 10;
            listOfItems = new T*[elementCapacity];
            elementCount = 0;
            }
        
        ~List()
            {
            delete [] listOfItems;
            }
        
        long count()
            {
            return(elementCount);
            }
        
        void addElement(T* element)
            {
            if (elementCount >= elementCapacity)
                {
                this->grow();
                }
            listOfItems[elementCount] = element;
            }
        
        T* elementAtIndex(long index)
            {
            if (elementCount > index)
                {
                return(listOfItems[index]);
                }
            return(NULL);
            }
        
    private:
        void grow()
            {
            long newSize = elementCapacity * 7 / 4;
            T** newList = new T*[newSize];
            memcpy((char*)newList,(char*)listOfItems,sizeof(T*) * elementCount);
            delete [] listOfItems;
            listOfItems = newList;
            elementCapacity = newSize;
            }
        
        T** listOfItems;
        long elementCount;
        long elementCapacity;
    };

#endif /* List_hpp */
