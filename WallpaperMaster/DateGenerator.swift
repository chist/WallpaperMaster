//
//  Calendar.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 19.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Day {
    var day:   Int
    var month: Int
    var year:  Int
    
    init(_ day: Int, ofMonth month: Int, inYear year: Int) {
        self.day   = day
        self.month = month
        self.year  = year
    }
    
    func getDate() -> Date {
        let components   = NSDateComponents()
        components.year  = self.year
        components.month = self.month
        components.day   = self.day
        
        if let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian) {
            return calendar.date(from: components as DateComponents)!
        } else {
            ErrorHandler.record("Gregorian calendar is not initialized.")
            return Date()
        }
    }
}

class DateGenerator {
    static func getCurrentDay() -> Day {
        return DateGenerator.getDay(from: Date())
    }
    
    static func getPreceding(by dayNumber: Int) -> Day {
        let curDate  = self.getCurrentDay().getDate()
        let interval = TimeInterval(-24 * 60 * 60 * dayNumber)
        let newDate  = Date(timeInterval: interval, since: curDate)
        return DateGenerator.getDay(from: newDate)
    }
    
    static func getRandomDay(after firstDay: Day) -> Day {
        let firstDate      = firstDay.getDate()
        let endDate        = self.getCurrentDay().getDate()
        let timeInterval   = endDate.timeIntervalSince(firstDate)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(timeInterval)))
        let newDate        = Date(timeInterval: randomInterval, since: firstDate)
        return DateGenerator.getDay(from: newDate)
    }
    
    private static func getDay(from date: Date) -> Day {
        let calendar = NSCalendar.current
        let year     = calendar.component(.year,  from: date)
        let month    = calendar.component(.month, from: date)
        let day      = calendar.component(.day,   from: date)
        return Day(day, ofMonth: month, inYear: year)
    }
}
