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

