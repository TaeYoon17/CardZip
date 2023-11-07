//
//  ImageService+CacheManager.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/07.
//

import UIKit
extension ImageService{
    func appendCache(type: SourceType,names:[String],size:CGSize? = nil) async throws{
        await withThrowingTaskGroup(of: Void.self) {[weak self] group in
            for name in names {
                group.addTask{[weak self] in
                    try await self?.appendCache(type: type,name: name, size: size)
                }
            }
        }
    }
    
    func appendCache(type: SourceType,name:String,size:CGSize? = nil) async throws{
        let keyName = if let size{
            "\(name)_\(Int(size.width))_\(Int(size.height))"
        }else { name }
        guard nil == cacheTable[type]?.object(forKey: keyName as NSString) else {
            return
        }
        do{
            let image = switch type{
            case .album: try await UIImage.fetchBy(link: name, ofSize: size)
            case .file: try await UIImage.fetchBy(fileName: name,ofSize: size)
            case .search: try await UIImage.fetchBy(identifier: name, ofSize: size)
            }
            cacheTable[type]?.setObject(image, forKey: keyName as NSString)
        }catch{
            throw error
        }
    }
    
    @MainActor func fetchByCache(type:SourceType,name: String, size:CGSize? = nil) async throws -> UIImage?{
        let keyStr = if let size{ "\(name)_\(Int(size.width))_\(Int(size.height))"
        }else { name }
        let image = if let size{
            await cacheTable[type]?.object(forKey: keyStr as NSString)?.byPreparingThumbnail(ofSize: size)
        }else{
            await cacheTable[type]?.object(forKey: keyStr as NSString)?.byPreparingForDisplay()
        }
        if let image{
            return image
        }else{
            try await appendCache(type: type, name: name, size: size)
        }
        try await Task.sleep(nanoseconds: 1000)
        return if let size{
            await cacheTable[type]?.object(forKey: keyStr as NSString)?.byPreparingThumbnail(ofSize: size)
        }else{
            await cacheTable[type]?.object(forKey: keyStr as NSString)?.byPreparingForDisplay()
        }
    }
    func appendCache(type: SourceType,name:String,maxSize:CGSize) async throws{
        let keyName = "\(name)_max_\(Int(maxSize.width))_\(Int(maxSize.height))"
        let image = switch type{
        case .album: try await UIImage.fetchBy(link: name)
        case .file: try await UIImage.fetchBy(fileName: name)
        case .search: try await UIImage.fetchBy(identifier: name)
        }
        guard let image else {throw FetchError.fetch}
        let ratio = min(1,min(maxSize.height / image.size.height, maxSize.width / image.size.width))
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        print(ratio,"비율ㄹ",size,"사이즈")
        guard let img = await image.byPreparingThumbnail(ofSize: size) else { return}
        
        cacheTable[type]?.setObject(img, forKey: keyName as NSString)
    }
    @MainActor func fetchByCache(type:SourceType,name: String, maxSize:CGSize) async throws -> UIImage?{
        let keyName = "\(name)_max_\(Int(maxSize.width))_\(Int(maxSize.height))"
        let image = cacheTable[type]?.object(forKey: keyName as NSString)
        if let image{
            return image
        }else{
            print("이거 호출")
            try await appendCache(type: type, name: name, maxSize: maxSize)
        }
        do{
            try await Task.sleep(nanoseconds: 1000)
        }catch{
            print(error)
        }
        print("fetchByCache!!")
        return cacheTable[type]?.object(forKey: keyName as NSString)
    }
}
