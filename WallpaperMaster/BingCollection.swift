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
    let contentURL      = "https://www.iorise.com/"
    let downloader = Downloader()
    
    func str2(_ num: Int) -> String {
        return String(format: "%02d", num)
    }
    
    func getLinkToImage(random: Bool) -> String? {
        let year: Int, month: Int, day: Int
        if random {
            year         = 2015 + Int(arc4random()) % 2
            month        = 1 + Int(arc4random()) % 12
            day          = 1 + Int(arc4random()) % 28
        } else {
            let date     = NSDate()
            let calendar = NSCalendar.current
            year         = calendar.component(.year,  from: date as Date)
            month        = calendar.component(.month, from: date as Date)
            day          = calendar.component(.day,   from: date as Date)
        }
        let monthLink = contentURL + "?m=\(year)" + str2(month) + str2(day)
        
        // get HTML content of page with month best photos
        let monthHTMLString = getHTML(link: monthLink)
        if monthHTMLString == nil {
            return nil
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
                return nil
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
            return nil
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getHTML(link: String) -> String? {
        let url = URL(string: link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        do {
            let html = try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
            return html as String
        } catch {
            print(error)
            return nil;
        }
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
