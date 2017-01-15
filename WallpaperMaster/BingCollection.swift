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
    let contentURL      = "http://www.istartedsomething.com/bingimages/"
    let imageContentURL = "http://www.istartedsomething.com/bingimages/cache/"
    let downloader = Downloader()
    
    func getLinkToImage(random: Bool) -> String? {
        let year: Int, month: Int, day: Int
        if random {
            year         = 2010 + Int(arc4random()) % 7
            month        = 1 + Int(arc4random()) % 12
            day          = 1 + Int(arc4random()) % 28
        } else {
            let date     = NSDate()
            let calendar = NSCalendar.current
            year         = calendar.component(.year,  from: date as Date)
            month        = calendar.component(.month, from: date as Date)
            day          = calendar.component(.day,   from: date as Date)
        }
        let monthLink = contentURL + "?m=\(month)&y=\(year)"
        print("month link: ", monthLink)
        
        // get HTML content of page with month best photos
        let monthHTMLString = getHTML(link: monthLink)
        if monthHTMLString == nil {
            return nil
        }
        
        do {
            // get description of a specific photo
            let monthHTML = try HTMLDocument(string: monthHTMLString!, encoding: String.Encoding.utf8)
            let xpath = "/html/body/div[4]//table[@class='calendar']//td[@class='dated']"
            let anchorArray = monthHTML.xpath(xpath)
            
            let dayIndex: Int = day - 1
            let piece = String(describing: anchorArray[dayIndex])
            
            // extract link to the album from description of a tiny photo
            let src = piece.searchQuotation(after: "data-original=")
            if src == nil {
                return nil
            }
            
            // avoid extra information in the link
            let offset = String(describing: "resize.php?i=").characters.count
            let linkEnd = src!.substring(from: src!.index(src!.startIndex, offsetBy: offset))
            let cropped = linkEnd.substring(to: linkEnd.characters.index(of: "&")!)
            return imageContentURL + cropped
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
