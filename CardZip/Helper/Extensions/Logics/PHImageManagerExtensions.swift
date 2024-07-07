//
//  PHImageManagerExtensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import Photos
import UIKit
extension PHImageManager{
    func fetchAssets(asset: PHAsset,deliveryMode:PHImageRequestOptionsDeliveryMode = .opportunistic ) async throws -> Data{
        try await withCheckedThrowingContinuation{ continueation in
            let option = PHImageRequestOptions()
//            option.deliveryMode = deliveryMode
            option.deliveryMode = .fastFormat
            print(asset)
            requestImageDataAndOrientation(for: asset, options: option) { imageData, val, _, _ in
                if let imageData{
                    print("굿굿굿")
                    continueation.resume(returning: imageData)
                }else{
                    print("데이터 못 가져옴!!")
                    continueation.resume(throwing: FetchError.fetch)
                }
            }
        }
    }
    func fetchAssets(asset: PHAsset) async throws -> UIImage?{
        return try await withCheckedThrowingContinuation { contiuation in
            let option = PHImageRequestOptions()
            option.deliveryMode = .fastFormat
            let ratio = asset.pixelHeight / asset.pixelWidth
            var flag = true
            self.requestImage(for: asset, targetSize: .init(width: 1080 * ratio, height: 1080), contentMode: .default, options: option) {[weak self] image, _ in
                if let image,flag{
                        contiuation.resume(returning: image)
                        flag = false
                }else{
                    print("데이터 못 가져옴!!")
                    contiuation.resume(throwing: FetchError.fetch)
                }
            }
        }
    }
}
