//
//  ArgonDateTime.swift
//  Argon
//
//  Created by Vincent Coetzee on 2018/12/03.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

import Foundation

public class DateTime
    {
    public private(set) var date:Date = Date()
    public private(set) var day:Int = -1
    public private(set) var month:Int = -1
    public private(set) var year:Int = -1
    public private(set) var hour:Int = -1
    public private(set) var minute:Int = -1
    public private(set) var second:Int = -1
    public private(set) var milliseconds:Int = -1
    public private(set) var nanoseconds:Int = -1
    public private(set) var timeZone:String = ""
    
    init(date:Date)
        {
        self.date = date
        }

    init(day:Int,month:Int,year:Int,timeZone:String? = nil)
        {
        self.day = day
        self.month = month
        self.year = year
        if timeZone != nil
            {
            self.timeZone = timeZone!
            }
        }
    
    convenience init(day:Int,month:Int,year:Int,hour:Int,minute:Int,second:Int,timeZone:String? = nil)
        {
        self.init(day:day,month:month,year:year,timeZone:timeZone)
        self.hour = hour
        self.minute = minute
        self.second = second
        }
    }
