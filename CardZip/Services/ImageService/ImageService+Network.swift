//
//  ImageService+Network.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import UIKit
extension ImageService{

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
        guard nil == searchCache.object(forKey: keyStr as NSString) else {
            print("이미 존재하는 아이템")
            return
        }
        do{
            let image = try await UIImage.fetchBy(link: link,ofSize: size)
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
}
