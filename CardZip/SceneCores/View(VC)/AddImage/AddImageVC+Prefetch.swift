//
//  AddImageVC+Prefetch.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
import Photos

extension AddImageVC{
//    func displayImage(identifier assetIdentifier:String) async -> UIImage? {
//        if let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject{
//            let manager = PHImageManager.default()
//            do{
//                let data = try await manager.fetchAssets(asset: asset)
//                let image = UIImage(data: data)
//                return await image?.byPreparingForDisplay()
//            }catch{
//                return nil
//            }
//        }
//        return nil
//    }
//    @MainActor func displayImage(identifiers assetIdentifier:[String]) async -> [UIImage] {
//        print(#function)
//        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifier, options: nil)
//        var images:[ UIImage] = []
//        let manager = PHImageManager.default()
//        for await asset in streamResult(results: fetchResult){
//            do{
//                let data = try await manager.fetchAssets(asset: asset)
//                guard let image = UIImage(data: data),
//                      let img = await image.byPreparingForDisplay() else {continue}
//                images.append( img)
//            }catch{ continue }
//        }
//        print(images)
//        return images
//    }
//    private func streamResult(results:PHFetchResult<PHAsset>)->AsyncStream<PHAsset>{
//        return AsyncStream { continuation in
//            results.enumerateObjects { asset, _, _ in
//                continuation.yield(asset)
//            }
//        }
//    }
}


