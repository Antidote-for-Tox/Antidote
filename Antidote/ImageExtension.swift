//
//  ImageExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

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

    func cropWithRect(var rect: CGRect) -> UIImage {
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
}
