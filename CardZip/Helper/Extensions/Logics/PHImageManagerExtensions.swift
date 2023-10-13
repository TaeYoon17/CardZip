//
//  PHImageManagerExtensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import Photos
extension PHImageManager{
    func fetchAssets(asset: PHAsset) async throws -> Data{
        try await withCheckedThrowingContinuation{ continueation in
            let option = PHImageRequestOptions()
            option.isSynchronous = false
            requestImageDataAndOrientation(for: asset, options: nil) { imageData, _, _, _ in
                if let imageData{
                    continueation.resume(returning: imageData)
                }else{
                    continueation.resume(throwing: FetchError.fetch)
                }
            }
        }
    }
}
