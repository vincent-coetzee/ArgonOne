//
//  CArchiver.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/12/04.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class CArchiver
    {
    public typealias ObjectType = NSObject&FileWritable
    
    private let ObjectMarker = 0xDEADBEEF
    private let ObjectReference = 0xBEADBABE
    private let ObjectEndMarker = 0xCAFED00D
    
    var file:UnsafeMutablePointer<FILE>
    var writtenObjects:[Int:NSObject] = [:]
    
    public init(path:String)
        {
        file = fopen(path,"w+t")
        var tableOffset = 0
        fwrite(&tableOffset,MemoryLayout<Int>.size,1,file)
        }
    
    public func write(object:ObjectType) throws
        {
        if writtenObjects[object.hashValue] == nil
            {
            var marker = ObjectMarker
            fwrite(&marker,MemoryLayout<Int>.size,1,file)
            let name = String(describing: type(of: object))
            try name.write(archiver: self)
            writtenObjects[object.hashValue] = object
            }
        else
            {
            var marker = ObjectReference
            fwrite(&marker,MemoryLayout<Int>.size,1,file)
            marker = object.hashValue
            fwrite(&marker,MemoryLayout<Int>.size,1,file)
            }
        }
    
    public func fclose() throws
        {
        var tablePosition = ftell(file)
        try writeTable()
        fseek(file,0,SEEK_SET)
        fwrite(&tablePosition,MemoryLayout<Int>.size,1,file)
        Darwin.fclose(file)
        }
    
    private func writeTable() throws
        {
        try ObjectEndMarker.write(archiver: self)
        try writtenObjects.count.write(archiver: self)
        for object in writtenObjects.values
            {
            try object.hashValue.write(archiver: self)
            let className = String(describing: type(of: object))
            try className.write(archiver: self)
            }
        }
    }
