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
        if let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject{
            let manager = PHImageManager.default()
            do{
                let data = try await manager.fetchAssets(asset: asset)
                let image = UIImage(data: data)
                return await image?.byPreparingForDisplay()
            }catch{
                return nil
            }
        }
        return nil
    }
}
//MARK: -- 이미지 부를때 애니메이션

