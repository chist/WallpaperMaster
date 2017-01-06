//
//  ImageGetter.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 04.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class KotomatrixCollection {
    var urlArray = [String]()
    let downloader = Downloader()
    
    init() {
        // получаем html-страницу с лучшими постами за случайный месяц
        let html = getHTML(link: generateTopMonthLink())

        do {
            // получаем узел с нужными картинками
            let doc = try HTMLDocument(string: html!, encoding: String.Encoding.utf8)
            let xpathString = "/html/body/sape_index/div[@id='main']/div/div[@id='rightside']//img[@title]"
            let anchorArray = doc.xpath(xpathString)
            
            // преобразуем узел в массив ссылок (строк)
            for element in anchorArray {
                urlArray.append(extractLink(from: String(describing: element)))
            }
        } catch let error {
            print(error)
        }
    }
    
    // генерируем ссылку на лучшие картинки за некоторый месяц
    func generateTopMonthLink() -> String {
        let topMonthLink = "http://kotomatrix.ru/topmonth/"
        let year  = 2009 + arc4random() % 7
        let month = 1 + arc4random() % 12
        return topMonthLink + String(year) + "-" + String(format: "%02d", month) + "-01"
    }
    
    // загружаем HTML-документ по заданной ссылке
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
    
    // извлекаем ссылку на картинку из её XML-описания
    func extractLink(from XMLString: String) -> String {
        var coincidence = [Int]()
        for (index, letter) in XMLString.characters.enumerated() {
            if letter == "\"" {
                coincidence.append(index)
            }
        }
        let index1 = XMLString.index(XMLString.startIndex, offsetBy: coincidence[0] + 1)
        let index2 = XMLString.index(XMLString.startIndex, offsetBy: coincidence[1] - 1)
        return XMLString[index1...index2]
    }
    
    func getRandomImage() -> NSImage? {
        if urlArray.count > 0 {
            let index = Int(arc4random()) % urlArray.count
            let link = urlArray[index]
            let data: Data
            do {
                data = try Data(contentsOf: URL(string: link)!)
                return NSImage(data: data)
            } catch let error {
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getImageOfTheDay() -> NSImage? {
        return nil
    }
}
