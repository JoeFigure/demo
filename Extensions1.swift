//
//  Extensions.swift
//  Bok
//
//  Created by Joe Kletz on 12/08/2017.
//  Copyright © 2017 Joe Kletz. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    static let aqua = #colorLiteral(red: 0.3921568627, green: 0.9529411765, blue: 0.8, alpha: 1)
    static let lightPurple = #colorLiteral(red: 0.5982880361, green: 0.4889590971, blue: 1, alpha: 1)
    static let veryLightGray = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    
}

//Show warning alert
extension UIViewController {
    func warningAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func truncate(_ length: Int, trailing: String? = nil) -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
    func stripHtml() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    func stripLineBreaks() -> String {
        return self.replacingOccurrences(of: "\n", with: "", options: .regularExpression)
    }
    
    func clockTimeToSeconds() -> Double {
        
        let val = self.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if( val.isEmpty ){ return 0 }
        
        let formats = [
            "HH:mm:ss.SSS"  : "^\\d{1,2}:\\d{2}:\\d{2}\\.\\d{1,3}$",
            "HH:mm:ss"      : "^\\d{1,2}:\\d{2}:\\d{2}$",
            "mm:ss.SSS"     : "^\\d{1,2}:\\d{2}\\.\\d{1,3}$",
            "mm:ss"         : "^\\d{1,2}:\\d{2}$",
            "ss.SSS"         : "^\\d{1,2}\\.\\d{1,3}$",
            ]
        
        // search for normal duration formats such as `00:05:01.2`
        for (format, pattern) in formats {
            
            if val.range(of: pattern, options: .regularExpression) != nil {
                
                let formatter = DateFormatter()
                formatter.dateFormat = format
                let time = formatter.date(from: val)
                
                if( time == nil ){ return 0 }
                
                formatter.dateFormat = "ss.SSS"
                let seconds = (formatter.string(from: time!) as NSString).doubleValue
                
                formatter.dateFormat = "mm"
                let minutes = (formatter.string(from: time!) as NSString).doubleValue
                
                formatter.dateFormat = "HH"
                let hours = (formatter.string(from: time!) as NSString).doubleValue
                
                return seconds + (minutes*60) + (hours*60*60)
            }
        }
        
        // if none of the more common formats match, check for other possible formats
        
        // 2345ms
        if val.range(of: "^\\d+ms$", options: .regularExpression) != nil{
            return (val as NSString).doubleValue / 1000.0
        }
        
        // 7.25h
        if val.range(of: "^\\d+(\\.\\d+)?h$", options: .regularExpression) != nil {
            return (val as NSString).doubleValue * 60 * 60
        }
        
        // 13min
        if val.range(of: "^\\d+(\\.\\d+)?min$", options: .regularExpression) != nil {
            return (val as NSString).doubleValue * 60
        }
        
        return 0
    }
    
    func clockTimeToMinutesString() -> String {
        
        let val = clockTimeToSeconds()
        
        let min = floor(val / 60)
        let sec = floor(val.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02.f:%02.f", min, sec)
    }
}

extension UIView {
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}


