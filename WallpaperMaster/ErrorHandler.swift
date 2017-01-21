//
//  Error.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 12.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation

class ErrorHandler {
    static func record(_ error: String) {
        print("Recording: ", error)
        
        let directory    = FileManager.SearchPathDirectory.documentDirectory
        let mask         = FileManager.SearchPathDomainMask.userDomainMask
        let paths        = NSSearchPathForDirectoriesInDomains(directory, mask, true)
        let documentsDir = paths.first
        let appFolder    = URL(fileURLWithPath: documentsDir!).appendingPathComponent("WallpaperMaster")
        let fileurl      =  appFolder.appendingPathComponent("log.txt")
        
        let string = getCurrentTime() + " " + error + "\n"
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        if FileManager.default.fileExists(atPath: fileurl.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: fileurl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                print("Error: cannot open fileHandle.")
            }
        }
        else {
            do {
                try data.write(to: fileurl)
            } catch {
                print("Error: cannot write data.")
            }
        }
    }
    
    private static func getCurrentTime() -> String {
        let date     = NSDate()
        let calendar = NSCalendar.current
        let year     = calendar.component(.year,   from: date as Date)
        let month    = calendar.component(.month,  from: date as Date)
        let day      = calendar.component(.day,    from: date as Date)
        let hour     = calendar.component(.hour,   from: date as Date)
        let minute   = calendar.component(.minute, from: date as Date)
        let second   = calendar.component(.second, from: date as Date)
        let calendarString = str2(day)  + "-" + str2(month)  + "-" + str2(year)
        let clockString    = str2(hour) + "-" + str2(minute) + "-" + str2(second)
        let timeString = calendarString + " " + clockString
        return timeString
    }
    
    private static func str2(_ num: Int) -> String {
        return String(format: "%02d", num)
    }
}
