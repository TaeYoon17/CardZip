//
//  ImageLoader.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import UIKit
final class ImageService{
    static let shared = ImageService()
    // 키 이름: 앨범ID_width_height
    private let albumCache = NSCache<NSString, UIImage>()
    private init(){}
    
    // 앨범에서 이미지 ID 리스트 fetch 병렬처리,
    func load(albumImageIds ids: [String],size:CGSize? = nil) async throws -> [String: UIImage] {
        // 병렬로 처리되는 이미지들 중 가장 늦게 완료된 것을 기다린다
        try await withThrowingTaskGroup(of: (String, UIImage?).self) { group in
            for id in ids {
                group.addTask{
                    let image: UIImage?
                    if let size{
                        image = await UIImage.fetchBy(identifier: id,ofSize: size)
                    }else{
                        image = await UIImage.fetchBy(identifier: id)
                    }
                    return (id, image)
                }
            }
            var imagesDict = [String: UIImage]()
            for try await (id, image) in group {
                if let image{ imagesDict[id] = image }
            }
            return imagesDict
        }
    }
    
    
    func appendCache(albumID: String,size: CGSize? = nil) async throws {
        let image:UIImage?
        let keyStr:String
        if let size{
            image = await UIImage.fetchBy(identifier: albumID,ofSize: size)
            keyStr = "\(albumID)_\(size.width)_\(size.height)"
        }else{
            image = await UIImage.fetchBy(identifier: albumID)
            keyStr = albumID
        }
        if let image{
            albumCache.setObject(image, forKey: keyStr as NSString)
        }else{
            throw FetchError.fetch
        }
    }
    func fetchByCache(albumID: String,size: CGSize? = nil) async throws -> UIImage?{
        let keyStr:String
        if let size{
            keyStr = "\(albumID)_\(size.width)_\(size.height)"
        }else{
            keyStr = albumID
        }
        if let image = albumCache.object(forKey: keyStr as NSString){ return image
        }else{
            Task.detached {
                do{
                    try await self.appendCache(albumID: albumID,size: size)
                }catch{
                    print(error)
                }
            }
            if let size{
                return await UIImage.fetchBy(identifier: albumID,ofSize: size)
            }else{
                return await UIImage.fetchBy(identifier: albumID)
            }
        }
    }
    
}
