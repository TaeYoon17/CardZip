//
//  UIImageDownSample.swift
//  CardZip
//
//  Created by 김태윤 on 12/13/23.
//

import UIKit
//MARK: -- 이미지 DownSample
extension UIImage{
    static func downSample(name:String,size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let path = Bundle.main.path(forResource: name, ofType: "PNG")!
        let url = NSURL(fileURLWithPath: path)
        
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(url, imageSourceOption)!
        let maxPixel = max(size.width, size.height) * scale
        let downSampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        
        let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions)!
        
        let newImage = UIImage(cgImage: downSampledImage)
        return newImage
    }
}
