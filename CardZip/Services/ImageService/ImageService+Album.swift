//
//  ImageService+AlbumCache.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import UIKit

extension ImageService{
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
    func appendEmptyCache(albumID:String,size: CGSize? = nil) async throws{
        if nil == albumCache.object(forKey: albumID as NSString){
            try await appendCache(albumID: albumID)
        }
    }
    @MainActor func fetchByCache(albumID: String,size: CGSize? = nil) async throws -> UIImage?{
        let keyStr:String
        let image: UIImage?
        if let size{
            keyStr = "\(albumID)_\(size.width)_\(size.height)"
            if let sizeImage = albumCache.object(forKey: keyStr as NSString){
                image = sizeImage
            }else{
                if let generalImage = albumCache.object(forKey: albumID as NSString){
                   image = await generalImage.byPreparingThumbnail(ofSize: size)
               }else{
                   image = await UIImage.fetchBy(identifier: albumID, ofSize: size)
               }
            }
        }else{
            keyStr = albumID
            if let generalImage = albumCache.object(forKey: albumID as NSString){
                image = generalImage
            }else{
                image = await UIImage.fetchBy(identifier: albumID)
            }
        }
        Task.detached {
            try await self.appendEmptyCache(albumID:keyStr,size:size)
        }
        return image
    }
}
