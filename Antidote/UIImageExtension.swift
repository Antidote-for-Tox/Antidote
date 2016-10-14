// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIImage {
    class func emptyImage() -> UIImage {
        return imageWithColor(.clearColor(), size: CGSize(width: 1, height: 1))
    }

    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: size)

        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    class func templateNamed(named: String) -> UIImage {
        return UIImage(named: named)!.imageWithRenderingMode(.AlwaysTemplate)
    }

    func scaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

       return newImage
    }

    func cropWithRect(rect: CGRect) -> UIImage {
        var rect = rect

        switch imageOrientation {
            case .Up:
                fallthrough
            case .UpMirrored:
                fallthrough
            case .Down:
                fallthrough
            case .DownMirrored:
                break

            case .Left:
                fallthrough
            case .LeftMirrored:
                fallthrough
            case .Right:
                fallthrough
            case .RightMirrored:
                var temp = rect.origin.x
                rect.origin.x = rect.origin.y
                rect.origin.y = temp

                temp = rect.size.width
                rect.size.width = rect.size.height
                rect.size.height = rect.size.width
        }

        if (scale > 1.0) {
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale
        }

        let imageRef = CGImageCreateWithImageInRect(self.CGImage, rect)!
        return UIImage(CGImage: imageRef, scale: scale, orientation: imageOrientation)
    }

    func flippedToCorrectLayout() -> UIImage {
        if #available(iOS 9.0, *) {
            return imageFlippedForRightToLeftLayoutDirection()
        }
        return self
    }
}
