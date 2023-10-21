//
//  PHImageManagerExtensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import Photos
extension PHImageManager{
    func fetchAssets(asset: PHAsset,deliveryMode:PHImageRequestOptionsDeliveryMode = .opportunistic ) async throws -> Data{
        try await withCheckedThrowingContinuation{ continueation in
            let option = PHImageRequestOptions()
            option.deliveryMode = deliveryMode
            requestImageDataAndOrientation(for: asset, options: option) { imageData, _, _, _ in
                if let imageData{
                    continueation.resume(returning: imageData)
                }else{
                    continueation.resume(throwing: FetchError.fetch)
                }
            }
        }
    }
}
