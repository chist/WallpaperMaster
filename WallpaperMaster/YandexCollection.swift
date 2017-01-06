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
    let contentURL = "https://fotki.yandex.ru/calendar/"
    let albumContentURL = "https://fotki.yandex.ru/next/calendar"
    let maxFailureCount: Int = 30
    // minimum value of image.width / image.height
    let proportionBound: CGFloat = 1.2
    
    func getLinkToRandomImage() -> String? {
        let year      = 2008 + arc4random() % 8
        let month     = 1 + arc4random() % 12
        let day       = 1 + Int(arc4random()) % 28
        let monthLink = contentURL + "?date=" + String(year) + "-" + String(format: "%02d", month)
        
        // get HTML content of page with month best photos
        let monthHTMLString = getHTML(link: monthLink)
        
        let linkToUserAlbum: String?
        do {
            // get description of a specific photo
            let monthHTML = try HTMLDocument(string: monthHTMLString!, encoding: String.Encoding.utf8)
            let xpath = "/html/body/div[3]/table/tr[3]/td[2]/table[2]//td[not(@class)]"
            let anchorArray = monthHTML.xpath(xpath)
            if anchorArray.count < day {
                print("Error: unknown error.")
            }
            let piece = String(describing: anchorArray[day - 1])
            
            // extract link to the album from description of a tiny photo
            let imageLink = piece.searchLink(after: "href=")
            if imageLink == nil {
                return nil
            }
            linkToUserAlbum = albumContentURL + imageLink!
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        let albumHTMLString = getHTML(link: linkToUserAlbum!)
        do {
            let albumHTML = try HTMLDocument(string: albumHTMLString!, encoding: String.Encoding.utf8)
            let xpath = "//script[3]"
            let anchorArray = albumHTML.xpath(xpath)
            
            // extract link from script description
            let piece = String(describing: anchorArray.first)
            return piece.searchLink(after: "\"xxxl\":{\"url\":")
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
    
    func downloadImage(from link: String) -> NSImage? {
        do {
            let data = try Data(contentsOf: URL(string: link)!)
            return NSImage(data: data)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getImageOfTheDay() -> NSImage? {
        return nil
    }
    
    func getRandomImage() -> NSImage? {
        var link: String? = nil
        
        // try to avoid removed images and vertically-oriented images
        var failureCount: Int = 0
        while failureCount < self.maxFailureCount {
            link = getLinkToRandomImage()
            if link == nil {
                failureCount = failureCount + 1
                continue
            }
            
            print(link!)
            let image = downloadImage(from: link!)
            
            if image == nil || image!.proportion < self.proportionBound {
                failureCount = failureCount + 1
                continue
            }
            return image
        }
        return nil
    }
}
