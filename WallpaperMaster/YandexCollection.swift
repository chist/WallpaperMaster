//
//  YandexCollection.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 06.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class YandexCollection: ImageGetterDelegate {
    private let contentURL      = "https://fotki.yandex.ru/calendar/"
    private let albumContentURL = "https://fotki.yandex.ru/next"
    private let downloader      = Downloader()
    private let maxFailureCount = 120
    // minimum value of image.width / image.height
    private let proportionBound: CGFloat = 1.2
    
    private func getLinkToImage(random: Bool) -> String? {
        let date: Day
        if random {
            let firstDay = Day(1, ofMonth: 1, inYear: 2008)
            date = DateGenerator.getRandomDay(after: firstDay)
        } else {
            date = DateGenerator.getCurrentDay()
        }
        let monthLink = contentURL + String(format: "?date=%d-%02d", date.year, date.month)
        
        // get HTML content of page with month best photos
        let monthHTMLString = monthLink.getHTML()
        if monthHTMLString == nil {
            return nil
        }
        
        let linkToUserAlbum: String?
        do {
            // get description of a specific photo
            let monthHTML = try HTMLDocument(string: monthHTMLString!, encoding: String.Encoding.utf8)
            let xpath = "/html/body/div[3]/table/tr[3]/td[2]/table[2]//td[not(@class)]"
            let anchorArray = monthHTML.xpath(xpath)
            
            var dayIndex: Int = date.day - 1
            // decrease day if current day photo hasn't appeared yet
            while anchorArray.count <= dayIndex {
                dayIndex = dayIndex - 1
            }
            let piece = String(describing: anchorArray[dayIndex])
            
            // extract link to the album from description of a tiny photo
            let imageLink = piece.searchQuotation(after: "href=")
            if imageLink == nil {
                return nil
            }
            linkToUserAlbum = albumContentURL + imageLink!
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        let albumHTMLString = linkToUserAlbum!.getHTML()
        do {
            let albumHTML = try HTMLDocument(string: albumHTMLString!, encoding: String.Encoding.utf8)
            let xpath = "//script[3]"
            let anchorArray = albumHTML.xpath(xpath)
            
            // extract link from script description
            let piece = String(describing: anchorArray.first)
            return piece.searchQuotation(after: "\"xxxl\":{\"url\":")
        } catch let error {
            print(error.localizedDescription)
            return nil
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
        var link: String? = nil
        
        // try to avoid removed images and vertically-oriented images
        var failureCount: Int = 0
        while failureCount < self.maxFailureCount {
            link = getLinkToImage(random: true)
            if link == nil {
                failureCount = failureCount + 1
                continue
            }
            
            let result = downloader.getImage(from: link!)
            
            if result.image == nil || result.image!.proportion < self.proportionBound {
                failureCount = failureCount + 1
                continue
            }
            return result
        }
        return DescribedImage()
    }
}
