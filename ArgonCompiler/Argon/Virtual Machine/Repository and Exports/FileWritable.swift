//
//  FileWritable.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/12/02.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public protocol FileWritable
    {
    init(archiver:CArchiver) throws
    func write(archiver:CArchiver) throws
    }

fileprivate let ObjectReference = 0xDEADBEEF
fileprivate let ObjectHeader = 0xBEADBABE

extension String:FileWritable
    {
    public init(archiver:CArchiver) throws
        {
        var count = 0
        fread(&count,MemoryLayout<Int>.size,1,archiver.file)
        var char:Character = " "
        var aString = ""
        for _ in 0..<count
            {
            fread(&char,MemoryLayout<Character>.size,1,archiver.file)
            aString += String(char)
            }
        self.init(aString)
        }
    
    public func write(archiver:CArchiver) throws
        {
        var count = self.count
        fwrite(&count,MemoryLayout<Int>.size,1,archiver.file)
        for char in self.utf8
            {
            var aChar = char
            fwrite(&aChar,1,1,archiver.file)
            }
        }
    }

extension Array:FileWritable where Element:FileWritable
    {
    public init(archiver:CArchiver) throws
        {
        var count = 0
        fread(&count,MemoryLayout<Int>.size,1,archiver.file)
        var array:[Element] = []
        for _ in 0..<count
            {
            array.append(try Element.init(archiver: archiver))
            }
        self.init(array)
        }
    
    public func write(archiver:CArchiver) throws
        {
        var count = self.count
        fwrite(&count,MemoryLayout<Int>.size,1,archiver.file)
        for element in self
            {
            try element.write(archiver: archiver)
            }
        }
    }

extension Bool:FileWritable
    {
    public init(archiver:CArchiver) throws
        {
        var count = 0
        fread(&count,MemoryLayout<Int>.size,1,archiver.file)
        self.init(count == 1)
        }
    
    public func write(archiver:CArchiver) throws
        {
        var count = self ? 1 : 0
        fwrite(&count,MemoryLayout<Int>.size,1,archiver.file)
        }
    }

extension Int:FileWritable
    {
    public init(archiver:CArchiver) throws
        {
        var count = 0
        fread(&count,MemoryLayout<Int>.size,1,archiver.file)
        self.init(count)
        }
    
    public func write(archiver:CArchiver) throws
        {
        var count = self
        fwrite(&count,MemoryLayout<Int>.size,1,archiver.file)
        }
    }
