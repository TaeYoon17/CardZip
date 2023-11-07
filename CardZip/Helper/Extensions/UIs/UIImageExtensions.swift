//
//  UIImageExtensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import Photos
// MARK: -- UIImage 폰트 간단하게 설정하기
extension UIImage{
    convenience init?(systemName: String,ofSize: CGFloat, weight: UIFont.Weight) {
        self.init(systemName: systemName,withConfiguration: .getConfig(ofSize: ofSize, weight: weight))
    }
}
// MARK: -- UIIMAGE CONFIGURATION Font설정 간단하게 가져오기
extension UIImage.Configuration{
    static func getConfig(ofSize: CGFloat, weight: UIFont.Weight)-> UIImage.SymbolConfiguration{
        let font = UIFont.systemFont(ofSize: ofSize, weight: weight)
        return UIImage.SymbolConfiguration(font: font)
    }
}
//MARK: -- 엘범 이미지 고유 아이디로 UIImage 가져오기
extension UIImage{
    static func fetchBy(identifier assetIdentifier:String) async -> UIImage?{
        let options = PHFetchOptions()
        options.wantsIncrementalChangeDetails = false
        if let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: options).firstObject{
            let manager = PHImageManager.default()
            do{
                let data = try await manager.fetchAssets(asset: asset)
                let image = UIImage(data: data)
                return await image?.byPreparingForDisplay()
            }catch{ return nil }
        }
        return nil
    }
    static func fetchBy(identifier assetIdentifier:String,ofSize: CGSize? = nil) async throws -> UIImage{
        let options = PHFetchOptions()
        options.wantsIncrementalChangeDetails = false
        if let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: options).firstObject{
            let manager = PHImageManager.default()
            do{
                let data = try await manager.fetchAssets(asset: asset)
                let image = UIImage(data: data)
                let img = if let ofSize{
                    await image?.byPreparingThumbnail(ofSize: ofSize)
                }else{
                    await image?.byPreparingForDisplay()
                }
                guard let img else{ throw FetchError.fetch}
                return img
            }catch{
                throw error
            }
        }
        else{
            throw FetchError.fetch
        }
    }
}
//MARK: -- 네트워크를 통해 이미지를 가져오기
extension UIImage{
    static func fetchBy(link:String,ofSize size:CGSize? = nil) async throws -> UIImage{
        guard let url = URL(string: link) else { throw FetchError.fetch }
        do{
            let data = try Data(contentsOf: url)
            let image = if let size{
                await UIImage(data: data)?.byPreparingThumbnail(ofSize: size)
            }else{
                await UIImage(data: data)?.byPreparingForDisplay()
            }
            guard let image else { throw FetchError.fetch }
            return image
        }catch{
            throw error
        }
    }
}
//MARK: -- 파일시스템을 통해 가져오기
extension UIImage{
    static func fetchBy(fileName: String,ofSize size: CGSize? = nil) async throws ->UIImage{
        if let image = UIImage.init(fileName: fileName){
            let img = if let size{
                await image.byPreparingThumbnail(ofSize: size)
            }else{
                await image.byPreparingForDisplay()
            }
            guard let img else { throw FetchError.fetch }
            return img
        }else{
            throw FetchError.fetch
        }
    }
}
