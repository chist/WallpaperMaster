//
//  RGOCollection.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 09.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class RGOCollection: ImageGetterDelegate {
    let contentURL       = "https://www.rgo.ru/ru/foto/foto-dnya"
    let randomContentURL = "https://www.rgo.ru/ru/foto/foto-dnya?page="
    let photosQuantity   = 180
    
    let downloader = Downloader()
    
    func getLinkToImage(random: Bool) -> String? {
        let pageLink: String
        if random {
            let num = Int(arc4random()) % self.photosQuantity
            pageLink = self.randomContentURL + "\(num)"
        } else {
            pageLink = self.contentURL
        }
        
        // get HTML content of page with photo
        let pageHTMLString = getHTML(link: pageLink)
        if pageHTMLString == nil {
            return nil
        }
        
        do {
            let pageHTML = try HTMLDocument(string: pageHTMLString!, encoding: String.Encoding.utf8)
            let xpath = "/html/body/div[@id='page']/div[@id='main']/div[@id='content']/div[@class='term-listing-heading']//article//div[@class='field-content']"
            let anchorArray = pageHTML.xpath(xpath)
            
            // extract link from script description
            if anchorArray.count == 0 {
                print("Error: search of xpath gave no results.")
                return nil
            }
            let piece = String(describing: anchorArray[anchorArray.count - 1])
            return piece.searchLink(after: "href=")
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

