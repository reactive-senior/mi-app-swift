//
//  Global.swift
//  Mi
//
//  Created by TED on 20/02/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import UIKit
import SystemConfiguration

let PrimaryColor = UIColor.init(red: 255, green: 87, blue: 51)


public class Global {

    var url = "https://mi-app.fr/app/"
    var version = "0.2a"
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    func daysBetweenDate(startDate: Date, endDate: Date) -> Int {
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year], from: startDate, to: endDate)
        return components.year!
    }

    
}

extension String {
    
    func localized() ->String {
        
        let preferences : UserDefaults = UserDefaults.standard
        let Language = preferences.string(forKey: "Language") ?? "en"
        
        
        let path = Bundle.main.path(forResource: Language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    func Baselocalized() ->String {
        
        let Language = "en"
        
        
        let path = Bundle.main.path(forResource: Language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            let wAttStr = try NSMutableAttributedString(data: data,  options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            
            wAttStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Helvetica",size: 14.0)!, range: NSMakeRange(0, wAttStr.length))
            
            
            wAttStr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white ,  range: NSRange(location:0,length:wAttStr.length))
            return wAttStr
            
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToAttributedStringBlack: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            let wAttStr = try NSMutableAttributedString(data: data,  options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            
            wAttStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Helvetica",size: 14.0)!, range: NSMakeRange(0, wAttStr.length))
            
            
            wAttStr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black ,  range: NSRange(location:0,length:wAttStr.length))
            
            return wAttStr
            
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
}



extension UIColor {
    
    

    
    
    convenience init(string: String) {
        
        var uppercasedString = string.uppercased()
        uppercasedString.remove(at: string.startIndex)
        
        var rgbValue: UInt32 = 0
        Scanner(string: uppercasedString).scanHexInt32(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}

extension UIStackView {
    
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
    
}

extension UITextField {
    func setBottomBorder(borderColor : UIColor) {
        self.borderStyle = UITextBorderStyle.none;
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = borderColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width - 4,  width:  self.frame.size.width, height:1)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String
{
    func substring(from index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: index))
    }
    
    func substring(to index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: index))
    }
    
    func substring(start: Int, end: Int) -> String
    {
        if (start < 0 || start > self.characters.count)
        {
            print("start index \(start) out of bounds")
            return ""
        }
        else if end < 0 || end > self.characters.count
        {
            print("end index \(end) out of bounds")
            return ""
        }
        let startIndex = self.characters.index(self.startIndex, offsetBy: start)
        let endIndex = self.characters.index(self.startIndex, offsetBy: end)
        let range = startIndex..<endIndex
        
        return self.substring(with: range)
    }
    
    func substring(start: Int, location: Int) -> String
    {
        if (start < 0 || start > self.characters.count)
        {
            print("start index \(start) out of bounds")
            return ""
        }
        else if location < 0 || start + location > self.characters.count
        {
            print("end index \(start + location) out of bounds")
            return ""
        }
        let startIndex = self.characters.index(self.startIndex, offsetBy: start)
        let endIndex = self.characters.index(self.startIndex, offsetBy: start + location)
        let range = startIndex..<endIndex
        
        return self.substring(with: range)
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        let attrs = [NSAttributedStringKey.font:  UIFont(name: "Helvetica-Bold", size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        //var attrs = [NSAttributedStringKey.font.rawValue : UIFont(name: "AvenirNext-Medium", size: 12)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}

extension UILabel
{
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            if let insets = padding {
                contentSize.height += insets.top + insets.bottom
                contentSize.width += insets.left + insets.right
            }
            return contentSize
        }
    }
}

