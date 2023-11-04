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
    private let searchCache = NSCache<NSString, UIImage>()
    private init(){}
    func getKeyname(albumID: String,size:CGSize? = nil)-> String{
        guard let size else {return albumID}
        return "\(albumID)_\(size.width)_\(size.height)"
    }
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
    
    func appendCache(links:[String],size:CGSize? = nil) async throws{
        await withThrowingTaskGroup(of: Void.self) {[weak self] group in
            for link in links {
                group.addTask{[weak self] in
                    try await self?.appendCache(link: link, size: size)
                }
            }
        }
    }
    func appendCache(link: String,size: CGSize? = nil) async throws{
        let keyStr = if let size{
            "\(link)_\(Int(size.width))_\(Int(size.height))"
        }else { "\(link)" }
        guard let url = URL(string: link) else { throw FetchError.fetch }
        guard nil == albumCache.object(forKey: keyStr as NSString) else {
            print("이미 존재하는 아이템")
            return
        }
        do{
            let data = try Data(contentsOf: url)
            let image = if let size{
                await UIImage(data: data)?.byPreparingThumbnail(ofSize: size)
            }else{
                await UIImage(data: data)?.byPreparingForDisplay()
            }
            guard let image else { throw FetchError.fetch }
            searchCache.setObject(image, forKey: keyStr as NSString)
        }catch{
            throw error
        }
    }
    @MainActor func fetchByCache(link: String, size:CGSize? = nil) async throws -> UIImage?{
        let keyStr = if let size{
            "\(link)_\(Int(size.width))_\(Int(size.height))"
        }else { 
            "\(link)"
        }
        let image = if let size{
            await searchCache.object(forKey: keyStr as NSString)?.byPreparingThumbnail(ofSize: size)
        }else{
            await searchCache.object(forKey: keyStr as NSString)?.byPreparingForDisplay()
        }
        if let image{ return image
        }else{
            try await appendCache(link: link,size: size)
        }
        return if let size{
            await searchCache.object(forKey: keyStr as NSString)?.byPreparingThumbnail(ofSize: size)
        }else{
            await searchCache.object(forKey: keyStr as NSString)?.byPreparingForDisplay()
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
