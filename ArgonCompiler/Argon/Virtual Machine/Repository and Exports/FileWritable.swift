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
    static func read(from:UnsafeMutablePointer<FILE>) throws -> FileWritable
    func write(to:UnsafeMutablePointer<FILE>) throws
    }
