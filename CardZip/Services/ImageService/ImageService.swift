//
//  ImageLoader.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import UIKit
extension ImageService{
    enum SourceType:CaseIterable{
        case album
        case search
        case file
    }
}
final class ImageService{
    static let shared = ImageService()
    // 키 이름: 앨범ID_width_height
    let cacheTable = SourceType.allCases.reduce(into: [:]) {
        $0[$1] = NSCache<NSString,UIImage>()    }
    private init(){}
    func getKeyname(albumID: String,size:CGSize? = nil)-> String{
        guard let size else {return albumID}
        return "\(albumID)_\(size.width)_\(size.height)"
    }
    func resetCache(type: SourceType){
        cacheTable[type]?.removeAllObjects()
    }
    
}
