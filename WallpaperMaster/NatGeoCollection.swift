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
    private let contentURL         = "http://www.nationalgeographic.com/photography/photo-of-the-day/_jcr_content/"
    private let photoCollectionURL = "http://yourshot.nationalgeographic.com"
    private let downloader         = Downloader()
    
    private func extractLink(from JSONString: String, random: Bool) -> String? {
        // get all links with desired resolution
        let resolution: Int = 2048
        let ranges: [NSRange] = JSONString.search(substring: "\"\(resolution)\":\"")
        if ranges.count == 0 {
            return nil
        }
        
        // select the serial number of link to be extracted
        let number: Int = random ? Int(arc4random()) % ranges.count : 0
        let range = ranges[number].range(for: JSONString)!
        
        // extract link
        let index1    = range.upperBound
        let cutString = JSONString.substring(from: index1)
        let index     = cutString.characters.index(of: "\"")!
        let offset    = cutString.distance(from: cutString.startIndex, to: index)
        let index2    = JSONString.index(index1, offsetBy: offset - 1)
        return JSONString[index1...index2]
    }

    
    private func getLinkToImageOfTheDay(source: String) -> String? {
        if let imageID = extractLink(from: source, random: false) {
            return photoCollectionURL + imageID
        }
        return nil
    }
    
    private func getLinkToRandomImage(source: String) -> String? {
        if let imageID = extractLink(from: source, random: true) {
            return photoCollectionURL + imageID
        }
        return nil
    }
    
    private func getCurrentMonth() -> String {
        let date = DateGenerator.getCurrentDay()
        return String(format: "%d-%02d", date.year, date.month)
    }
    
    private func getRandomMonth() -> String {
        let day  = Day(1, ofMonth: 8, inYear: 2016)
        let date = DateGenerator.getRandomDay(after: day)
        return String(format: "%d-%02d", date.year, date.month)
    }
    
    func getImageOfTheDay() -> DescribedImage {
        let link = contentURL + ".gallery." + getCurrentMonth() + ".json"
        if let JSONString = link.getHTML() {
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
        if let JSONString = link.getHTML() {
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
