//
//  UIColor+Extension.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 8/5/24.
//

import UIKit

struct ColorRBGA {
    var red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat
}

extension UIColor {

    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1)
    }

    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hexWithoutSymbol = String(hex.suffix(from: index))
        }

        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt: UInt64 = 0x0
        scanner.scanHexInt64(&hexInt)

        var red :UInt64!, green :UInt64!, blue :UInt64!
        switch hexWithoutSymbol.count {
        case 3: // #RGB
            red = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            green = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            blue = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
        case 6: // #RRGGBB
            red = (hexInt >> 16) & 0xff
            green = (hexInt >> 8) & 0xff
            blue = hexInt & 0xff
        default:
            break
        }

        self.init(
            red: (CGFloat(red)/255),
            green: (CGFloat(green)/255),
            blue: (CGFloat(blue)/255),
            alpha: alpha)
    }

    var rgba: ColorRBGA {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return ColorRBGA(red: red, green: green, blue: blue, alpha: alpha)
    }

    func isLightColor() -> Bool {
        let detailColor = self.rgba
        let lumen = ((detailColor.red * 255) * 0.299) + ((detailColor.green * 255) * 0.587) + ((detailColor.blue  * 255) * 0.114)
        return lumen > 186
    }

//    for each c in r,g,b:
//    c = c / 255.0
//    if c <= 0.03928 then c = c/12.92 else c = ((c+0.055)/1.055) ^ 2.4

    func isLightColorBT709() -> Bool {
        let detailColor = self.rgba
        let red2 = detailColor.red.getBT709Value()
        let green2 = detailColor.green.getBT709Value()
        let blue2 = detailColor.blue.getBT709Value()
        let lumen = 0.2126 * red2 + 0.7152 * green2 + 0.0722 * blue2
        return lumen > 0.179
    }

    func alpha(_ alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

extension CGFloat {
    func getBT709Value() -> CGFloat {
        let bt709 = self <= 0.03928 ? self / 12.92 : pow((( self + 0.055 ) / 1.055 ), 2.4)
        return bt709
    }
}

extension UIColor {
    @nonobjc class var paleGreyThree: UIColor {
      return UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var darkSkyBlue: UIColor {
        return UIColor(red: 31.0 / 255.0, green: 131.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    }
}

