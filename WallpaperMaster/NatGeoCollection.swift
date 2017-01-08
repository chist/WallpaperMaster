//
//  RGOCollection.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 05.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//
// stackoverflow.com/questions/32285412/how-to-find-all-positions-of-one-string-in-another-string-in-swift2
// hackingwithswift.com/example-code/language/how-to-convert-an-nsrange-to-a-swift-string-index

import Foundation
import Cocoa

class NatGeoCollection: ImageGetterDelegate {
    let contentURL         = "http://www.nationalgeographic.com/photography/photo-of-the-day/_jcr_content/"
    let photoCollectionURL = "http://yourshot.nationalgeographic.com"
    let downloader = Downloader()
    
    func getSource(link: String) -> String? {
        let url = URL(string: link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        do {
            let source = try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
            return source as String
        } catch let error {
            print(error.localizedDescription)
            return nil;
        }
    }
    
    func extractLink(from JSONString: String, random: Bool) -> String? {
        let searchString = "\"2048\":\""
        let ranges: [NSRange]
        
        do {
            // Create the regular expression.
            let regExpr = try NSRegularExpression(pattern: searchString, options: [])
            
            // Use the regular expression to get an array of NSTextCheckingResult.
            // Use map to extract the range from each result.
            let length = JSONString.characters.count
            let matches = regExpr.matches(in: JSONString, options: [], range: NSMakeRange(0, length))
            ranges = matches.map{$0.range}
        } catch {
            ranges = []
        }
        
        if ranges.count == 0 {
            return nil
        }
        
        let number: Int = random ? Int(arc4random()) % ranges.count : 0
        let range = ranges[number].range(for: JSONString)!
        
        let index1    = range.upperBound
        let cutString = JSONString.substring(from: index1)
        let index     = cutString.characters.index(of: "\"")!
        let offset    = cutString.distance(from: cutString.startIndex, to: index)
        let index2    = JSONString.index(index1, offsetBy: offset - 1)
        return JSONString[index1...index2]
    }

    
    func getLinkToImageOfTheDay(source: String) -> String? {
        if let imageID = extractLink(from: source, random: false) {
            return photoCollectionURL + imageID
        }
        return nil
    }
    
    func getLinkToRandomImage(source: String) -> String? {
        if let imageID = extractLink(from: source, random: true) {
            return photoCollectionURL + imageID
        }
        return nil
    }
    
    func getCurrentMonth() -> String {
        let date     = NSDate()
        let calendar = NSCalendar.current
        let year     = calendar.component(.year, from: date as Date)
        let month    = calendar.component(.month, from: date as Date)
        return String(year) + "-" + String(format: "%02d", month)
    }
    
    func getRandomMonth() -> String {
        let year     = 2016
        let month    = 8 + Int(arc4random()) % 5
        return String(year) + "-" + String(format: "%02d", month)
    }
    
    func getImageOfTheDay() -> DescribedImage {
        let link = contentURL + ".gallery." + getCurrentMonth() + ".json"
        if let JSONString = getSource(link: link) {
            let link = getLinkToImageOfTheDay(source: JSONString)
            if link == nil {
                return DescribedImage()
            }
            return downloader.getImage(from: link!)
        } else {
            print("Error: failed to get JSON object.")
            return DescribedImage()
        }
    }
    
    func getRandomImage() -> DescribedImage {
        let link = contentURL + ".gallery." + getRandomMonth() + ".json"
        if let JSONString = getSource(link: link) {
            let link = getLinkToRandomImage(source: JSONString)
            if link == nil {
                return DescribedImage()
            }
            return downloader.getImage(from: link!)
        } else {
            print("Error: failed to get JSON object.")
            return DescribedImage()
        }
    }
}
