//
//  Extensions.swift
//  CardZip
//
//  Created by 김태윤 on 12/5/23.
//

import UIKit
import Photos
import PhotosUI
extension NSItemProvider{
    func loadimage() async throws ->UIImage?{
        let type: NSItemProviderReading.Type = UIImage.self
        return try await withCheckedThrowingContinuation { continuation in
            loadObject(ofClass: type) { (image, error) in
                if let error{
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: image as? UIImage)
            }
        }
    }
}
extension UIImage{
    static func fetchBy(phResult: PHPickerResult) async throws -> UIImage{
        let item = phResult.itemProvider 
        guard let image = try await item.loadimage() else {
            throw ImageServiceError.PHAssetFetchError
        }
        return image
    }
}

enum ImageServiceError:Error{
    case fetchError
    case PHAssetFetchError
}
