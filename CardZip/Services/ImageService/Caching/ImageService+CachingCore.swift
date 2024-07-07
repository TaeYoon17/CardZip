//
//  ImageService+CacheManager.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/07.
//

import UIKit
//MARK: -- CoreLoagic
extension ImageService{
     func fetchImage(type:SourceType,name:String,ofSize:CGSize? = nil) async throws -> UIImage{
        return switch type{
        case .album: try await UIImage.fetchBy(identifier: name,ofSize: ofSize)
        case .file: try await UIImage.fetchBy(fileName: name,ofSize: ofSize)
        case .search: try await UIImage.fetchBy(link: name,ofSize: ofSize)
        }
    }
     func downSizeToMax(image: UIImage,maxSize: CGSize) async throws -> UIImage{
        let size = CGSize(original: image.size, max: maxSize)
        if let img = await image.byPreparingThumbnail(ofSize: size){
            return img
        }else{
            throw FetchError.load
        }
    }
    func _appendCache(type: SourceType,image:UIImage,keyName:String) async {
        cacheTable[type]?.setObject(image, forKey: keyName as NSString)
    }
    func getKeyName(name:String,size:CGSize? = nil) -> String{
        return if let size{ "\(name)_\(Int(size.width))_\(Int(size.height))"
        }else { name }
    }
    
}
// MARK: -- 이미지 캐싱 기본 구성
extension ImageService{
    func appendCache(type: SourceType,name:String,size:CGSize? = nil,isCover:Bool = false) async throws{
        let keyName = getKeyName(name: name,size: size)
        if cacheTable[type]?.object(forKey: keyName as NSString) != nil && isCover == false { return}
        let image = try await fetchImage(type: type, name: name,ofSize: size)
        await _appendCache(type: type, image: image, keyName: keyName)
    }
    func appendCache(type: SourceType,names:[String],size:CGSize? = nil) async throws{
        await withThrowingTaskGroup(of: Void.self) {[weak self] group in
            for name in names {
                group.addTask{[weak self] in
                    try await self?.appendCache(type: type,name: name, size: size)
                }
            }
        }
    }
    @MainActor func fetchByCache(type:SourceType,name: String,size:CGSize? = nil) async throws -> UIImage?{
        let keyName = getKeyName(name: name,size: size)
        if let image = cacheTable[type]?.object(forKey: keyName as NSString){
            return image
        }else{
            let image = try await fetchImage(type: type, name: name,ofSize: size)
            Task.detached {
                await self._appendCache(type: type, image: image, keyName: keyName)
            }
            return image
        }
    }
}

//MARK: 이미지 서비스 최대 크기 제한 가져오기
extension ImageService{
    func appendCache(type: SourceType,name:String,maxSize:CGSize,isCover: Bool = false) async throws{
        let keyName = getKeyName(name: name,size: maxSize)
        if cacheTable[type]?.object(forKey: keyName as NSString) != nil && isCover == false { return}
        let image = try await fetchImage(type: type, name: name)
        let img = try await downSizeToMax(image: image, maxSize: maxSize)
        await _appendCache(type: type, image: img, keyName: keyName)
    }
    @MainActor func fetchByCache(type:SourceType,name: String, maxSize:CGSize) async throws -> UIImage?{
        let keyName = getKeyName(name: name,size: maxSize)
        if let image = cacheTable[type]?.object(forKey: keyName as NSString){
            return image
        }else{
            let image = try await fetchImage(type: type, name: name)
            let img = try await downSizeToMax(image: image, maxSize: maxSize)
            Task.detached {
                await self._appendCache(type:type, image: image, keyName: keyName)
            }
            return img
        }
    }
}
