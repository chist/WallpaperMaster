//
//  BingCollection.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 15.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class BingCollection: ImageGetterDelegate {
    private let contentURL           = "https://www.iorise.com/"
    private let downloader           = Downloader()
    private let maxFailureCount: Int = 2
    
    private func str2(_ num: Int) -> String {
        return String(format: "%02d", num)
    }
    
    private func getLinkToImage(random: Bool) -> String? {
        var triesCount: Int = 0
        
        while triesCount < maxFailureCount {
            let date: Day
            if random {
                let firstDay = Day(1, ofMonth: 1, inYear: 2015)
                date = DateGenerator.getRandomDay(after: firstDay)
            } else {
                date = DateGenerator.getPreceding(by: triesCount)
            }
            let monthLink = contentURL + "?m=\(date.year)" + str2(date.month) + str2(date.day)
            
            triesCount = triesCount + 1
            
            // get HTML content of page with month best photos
            let monthHTMLString = monthLink.getHTML()
            if monthHTMLString == nil {
                continue
            }
            
            do {
                // get some text containing image links
                let monthHTML = try HTMLDocument(string: monthHTMLString!, encoding: String.Encoding.utf8)
                let xpath = "/html//div[@class='entry-content']"
                let anchorArray = monthHTML.xpath(xpath)
                var text = ""
                for element in anchorArray {
                    text = text + "\n" + String(describing: element)
                }
                
                // get all the image links from web page
                let ranges: [NSRange] = text.search(substring: "href=\"")
                if ranges.count == 0 {
                    continue
                }
                
                // store all links as [String]
                var links = [String]()
                for nsRange in ranges {
                    // convert NSRange to Range
                    let range = nsRange.range(for: text)!
                    
                    let index1    = range.upperBound
                    let cutString = text.substring(from: index1)
                    let index     = cutString.characters.index(of: "\"")!
                    let offset    = cutString.distance(from: cutString.startIndex, to: index)
                    let index2    = text.index(index1, offsetBy: offset - 1)
                    links.append(text[index1...index2])
                }
                
                // find link to image with desired resolution
                let best = "1920x1080" // without logo
                for link in links {
                    if link.search(substring: best).count > 0 {
                        return link
                    }
                }
                let good = "1920x1200"
                for link in links {
                    if link.search(substring: good).count > 0 {
                        return link
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getImageOfTheDay() -> DescribedImage {
        let link = getLinkToImage(random: false)
        if link != nil {
            return downloader.getImage(from: link!)
        }
        return DescribedImage()
    }
    
    func getRandomImage() -> DescribedImage {
        let link = getLinkToImage(random: true)
        if link != nil {
            return downloader.getImage(from: link!)
        }
        return DescribedImage()
    }
}
