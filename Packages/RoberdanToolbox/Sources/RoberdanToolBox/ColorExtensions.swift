//
//  ColorExtensions.swift
//
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

#if os(iOS)

    import Foundation
    import SwiftUI
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public extension UIColor {
        struct RGBColor {
            public let red: CGFloat
            public let green: CGFloat
            public let blue: CGFloat
            public let alpha: CGFloat

            init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
                self.red = red
                self.green = green
                self.blue = blue
                self.alpha = alpha
            }
        }

        struct HSBColor {
            public let hue: CGFloat
            public let saturation: CGFloat
            public let brightness: CGFloat
            public let alpha: CGFloat

            init(_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat, _ alpha: CGFloat) {
                self.hue = hue
                self.saturation = saturation
                self.brightness = brightness
                self.alpha = alpha
            }
        }

        var rgbComponents: RGBColor {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                return RGBColor(red, green, blue, alpha)
            }
            return RGBColor(0, 0, 0, 0)
        }

        // hue, saturation, brightness and alpha components from UIColor**
        var hsbComponents: HSBColor {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return HSBColor(hue, saturation, brightness, alpha)
            }
            return HSBColor(0, 0, 0, 0)
        }

        var htmlRGBColor: String {
            String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255), Int(rgbComponents.blue * 255))
        }

        var toJson: String {
            String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255), Int(rgbComponents.blue * 255))
        }

        var htmlRGBaColor: String {
            String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255), Int(rgbComponents.blue * 255), Int(rgbComponents.alpha * 255))
        }
        //  sample use
        //    let myColorBlack = UIColor.blackColor().toJson         //#000000ff
        //    let myLghtGrayColor = UIColor.lightGrayColor().toJson  //#aaaaaaff
        //    let myDarkGrayColor = UIColor.darkGrayColor().toJson
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public extension UIColor {
        convenience init(hexString: String, alpha: CGFloat = 1.0) {
            let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let scanner = Scanner(string: hexString)
            // Tell scanner to skip the # character
            scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")

            var color: UInt64 = 0
            // Scan hex value
            scanner.scanHexInt64(&color)
            let mask = 0x0000_00FF
            let redInt = Int(color >> 16) & mask
            let greenInt = Int(color >> 8) & mask
            let blueInt = Int(color) & mask
            let red = CGFloat(redInt) / 255.0
            let green = CGFloat(greenInt) / 255.0
            let blue = CGFloat(blueInt) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }

        func toHexString() -> String {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
            return String(format: "#%06x", rgb)
        }

        func toUint() -> UInt {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let rgb: UInt = (UInt)(red * 255) << 16 | (UInt)(green * 255) << 8 | (UInt)(blue * 255) << 0
            return rgb
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public extension UIColor {
        var color: Color {
            let rgbColours = cgColor.components
            if rgbColours?.count == 2 {
                return Color(
                    red: Double(rgbColours![0]),
                    green: Double(rgbColours![1]),
                    blue: Double(0.0)
                )
            } else {
                return Color(
                    red: Double(rgbColours![0]),
                    green: Double(rgbColours![1]),
                    blue: Double(rgbColours![2])
                )
            }
        }

        func rgb() -> Int? {
            var fRed: CGFloat = 0
            var fGreen: CGFloat = 0
            var fBlue: CGFloat = 0
            var fAlpha: CGFloat = 0
            if getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
                let iRed = Int(fRed * 255.0)
                let iGreen = Int(fGreen * 255.0)
                let iBlue = Int(fBlue * 255.0)
                let iAlpha = Int(fAlpha * 255.0)

                //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
                let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
                return rgb
            } else {
                // Could not extract RGBA components:
                return nil
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public extension Color {
        struct RGBColor {
            public let red: CGFloat
            public let green: CGFloat
            public let blue: CGFloat
            public let alpha: CGFloat

            init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
                self.red = red
                self.green = green
                self.blue = blue
                self.alpha = alpha
            }
        }

        func uiColor() -> UIColor {
            let components = components()
            return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
        }

        private func components() -> RGBColor {
            let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

            let result = scanner.scanHexInt64(&hexNumber)
            if result {
                red = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
                green = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
                blue = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
                alpha = CGFloat(hexNumber & 0x0000_00FF) / 255
            }
            return RGBColor(red, green, blue, alpha)
        }

        init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let alpha, red, green, blue: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (alpha, red, green, blue) = (1, 1, 1, 0)
            }

            self.init(
                .sRGB,
                red: Double(red) / 255,
                green: Double(green) / 255,
                blue: Double(blue) / 255,
                opacity: Double(alpha) / 255
            )
        }
    }

    /// Allows you to use Swift encoders and decoders to process UIColor

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public extension UIColor {
        func codable() -> CodableColor {
            CodableColor(color: self)
        }
    }

    public struct CodableColor {
        /// The color to be (en/de)coded
        let color: UIColor
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    extension CodableColor: Encodable {
        public func encode(to encoder: Encoder) throws {
            let nsCoder = NSKeyedArchiver(requiringSecureCoding: true)
            color.encode(with: nsCoder)
            var container = encoder.unkeyedContainer()
            try container.encode(nsCoder.encodedData)
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    extension CodableColor: Decodable {
        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            let decodedData = try container.decode(Data.self)
            let nsCoder = try NSKeyedUnarchiver(forReadingFrom: decodedData)
            guard let color = UIColor(coder: nsCoder) else {
                struct UnexpectedlyFoundNilError: Error {}
                throw UnexpectedlyFoundNilError()
            }
            self.color = color
        }
    }

#endif
