//
//  ArgonWordFile.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/11/18.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation
import SharedMemory

public class ArgonWordFile
    {
    private static let kMagicNumber = 0xF00D4DEADD0D0
    
    private var currentOffsetInFile:ArgonWord = 0
    private var wordBuffer:[ArgonWord] = []
    
    public func writeWord(_ word:ArgonWord)
        {
        wordBuffer.append(word)
        }
    
    @discardableResult
    public func writeObject(pointer:Pointer) -> ArgonWord
        {
        let thisOffset = currentOffsetInFile
        let slotCount = slotCountOfInstance(pointer)
        for index in Int32(0)..<Int32(slotCount)
            {
            let word = wordAtIndexAtPointer(index,pointer)
            let wordPointer = wordAsPointer(word)
            if isTaggedPointer(wordPointer)
                {
                let offset = self.currentOffsetInFile
                self.writeObject(pointer: untaggedPointer(wordPointer))
                self.writeWord(taggedRelocationOffset(offset))
                }
            else
                {
                self.writeWord(word)
                }
            }
        return(thisOffset)
        }
    }
