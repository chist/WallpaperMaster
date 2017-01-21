//
//  Extensions.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 06.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

extension String {
    func searchQuotation(after substring: String) -> String? {
        if let index1 = self.range(of: substring + "\"")?.upperBound {
            let cutString = self.substring(from: index1)
            let index     = cutString.characters.index(of: "\"")!
            let offset    = cutString.distance(from: cutString.startIndex, to: index)
            let index2    = self.index(index1, offsetBy: offset - 1)
            
            return self[index1...index2]
        } else {
            return nil
        }
    }
    
    func search(substring: String) -> [NSRange] {
        let ranges: [NSRange]
        do {
            // Create the regular expression.
            let regExpr = try NSRegularExpression(pattern: substring, options: [])
            
            // Use the regular expression to get an array of NSTextCheckingResult.
            // Use map to extract the range from each result.
            let length = self.characters.count
            let matches = regExpr.matches(in: self, options: [], range: NSMakeRange(0, length))
            ranges = matches.map{$0.range}
        } catch {
            ranges = []
        }
        return ranges
    }
    
    // download HTML if object represents a link
    func getHTML() -> String? {
        let url = URL(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        do {
            let html = try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
            return html as String
        } catch {
            print(error)
            return nil;
        }
    }
}

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}

extension NSImage {
    var proportion: CGFloat {
        return self.size.width / self.size.height
    }
}
