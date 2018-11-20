//
//  Timer.swift
//  Apollo
//
//  Created by Vincent Coetzee on 2018/07/24.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct Timer
    {
    private let startTime:UInt64
    
    static func timeInMilliseconds() -> UInt64
        {
        var time = UnsafeMutablePointer<timespec>.allocate(capacity: 1)
        time.initialize(repeating: timespec(tv_sec: 0,tv_nsec:0), count: 1)
        defer
            {
            time.deallocate()
            }
        clock_gettime(CLOCK_REALTIME, time)
        let result = UInt64(time.pointee.tv_sec)*UInt64(1000) + (UInt64(time.pointee.tv_nsec) / UInt64(1_000_000))
        return(result)
        }
    
    public static func time(closure: () -> Void) -> UInt64
        {
        let timer = Timer()
        closure()
        return(timer.stop())
        }
    
    static func timeInUnits(milliseconds value:UInt64) -> (Int,Int,Int,Int)
        {
        assert(value > 0)
        let millisecondsPerSecond:UInt64 = 1_000
        let millisecondsPerMinute:UInt64 = 60_000
        let millisecondsPerHour:UInt64 = 3_600_000
        let hours = value / millisecondsPerHour
        var remainder = value - (millisecondsPerHour * hours)
        let minutes = remainder / millisecondsPerMinute
        remainder = remainder - (millisecondsPerMinute * minutes)
        let seconds = remainder / millisecondsPerSecond
        let milliseconds = remainder - (millisecondsPerSecond * seconds)
        return(Int(hours),Int(minutes),Int(seconds),Int(milliseconds))
        }
    
    init()
        {
        startTime = Timer.timeInMilliseconds()
        }
    
    func stop() -> UInt64
        {
        let endTime = Timer.timeInMilliseconds()
        return(endTime - startTime)
        }
    }
