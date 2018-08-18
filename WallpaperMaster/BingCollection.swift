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
    private let contentURL           = "https://bingwallpaper.com/"
    private let downloader           = Downloader()
    private let maxFailureCount: Int = 5
    
    private func str2(_ num: Int) -> String {
        return String(format: "%02d", num)
    }
    
    private func getLinkToImage(random: Bool) -> String? {
        var triesCount: Int = 0
        
        while triesCount < maxFailureCount {
            let date: Day
            if random {
                let firstDay = Day(8, ofMonth: 6, inYear: 2018)
                date = DateGenerator.getRandomDay(after: firstDay)
            } else {
                date = DateGenerator.getPreceding(by: triesCount)
            }
            let monthLink = contentURL + "\(date.year)" + str2(date.month) + str2(date.day) + ".html"
            
            triesCount = triesCount + 1
            
            // get HTML content of page with month best photos
            let monthHTMLString = monthLink.getHTML()
            if monthHTMLString == nil {
                continue
            }
            
            do {
                // get some text containing image links
                let monthHTML = try HTMLDocument(string: monthHTMLString!, encoding: String.Encoding.utf8)
                let xpath = "//*[@id=\"photos\"]/div/div[1]/img"
                let anchorArray = monthHTML.xpath(xpath)
                
                if anchorArray.count == 0 {
                    continue
                }
                
                let text = String(describing: anchorArray[0])
                
                // get all the image links from web page
                let ranges: [NSRange] = text.search(substring: "img src=\"//")
                if ranges.count == 0 {
                    continue
                }
                
                // extract link to the image
                let index1    = String.Index(encodedOffset: ranges[0].upperBound)
                let cutString = text[index1...]
                let index     = cutString.index(of: "\"")!
                let offset    = cutString.distance(from: cutString.startIndex, to: index)
                let index2    = text.index(index1, offsetBy: offset - 1)
                let link = String(text[index1...index2])
                
                return link

            } catch let error {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func getSuperResolutionLink(link: String) -> String {
        let ranges: [NSRange] = link.search(substring: "_")
        
        if ranges.count == 0 {
            return link
        }
        
        // extract current resolution
        let index1    = String.Index(encodedOffset: ranges.last!.upperBound)
        let cutString = link[index1...]
        let index     = cutString.index(of: ".")!
        let offset    = cutString.distance(from: cutString.startIndex, to: index)
        let index2    = link.index(index1, offsetBy: offset - 1)
        let curRes = String(link[index1...index2])
        
        let newLink = link.replacingOccurrences(of: curRes, with: "1920x1200", options: .literal, range: nil)
        return newLink
    }
    
    private func getImage(link: String?) -> DescribedImage {
        if link != nil {
            let correctedLink = "http://" + link!
//            let superResLink = getSuperResolutionLink(link: correctedLink)
//            let superImg = downloader.getImage(from: superResLink)
//            if superImg.image != nil {
//                return superImg
//            }
            return downloader.getImage(from: correctedLink)
        }
        return DescribedImage()
    }
    
    func getImageOfTheDay() -> DescribedImage {
        let link = getLinkToImage(random: false)
        return getImage(link: link)
    }
    
    func getRandomImage() -> DescribedImage {
        let link = getLinkToImage(random: true)
        return getImage(link: link)
    }
}
