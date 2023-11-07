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
    let albumCache = NSCache<NSString, UIImage>()
    let searchCache = NSCache<NSString, UIImage>()
    let fileCache = NSCache<NSString,UIImage>()
    let cacheTable = SourceType.allCases.reduce(into: [:]) {
        $0[$1] = NSCache<NSString,UIImage>()
    }
    private init(){}
    func getKeyname(albumID: String,size:CGSize? = nil)-> String{
        guard let size else {return albumID}
        return "\(albumID)_\(size.width)_\(size.height)"
    }
    func resetCache(type: SourceType){
        cacheTable[type]?.removeAllObjects()
        switch type{
        case .album:
            albumCache.removeAllObjects()
        case .search:
            searchCache.removeAllObjects()
        case .file:
            fileCache.removeAllObjects()
        }
    }
    func saveToDocumentBy(photoID: String) async {
        let image = await UIImage.fetchBy(identifier: photoID)
        if !FileManager.checkExistDocument(fileName: "albumImage\(photoID)", type: .jpg){
            image?.saveToDocument(fileName: "albumImage\(photoID)")
        }
    }
    func saveToDocumentBy(photoIDs: [String]) async{
        await withThrowingTaskGroup(of: Void.self) {[weak self] group in
            for photoID in photoIDs {
                group.addTask{[weak self] in
                    await self?.saveToDocumentBy(photoID: photoID)
                }
            }
        }
    }
    //    func saveToDocument(fileName: String) async {
    //        let name = if fileName.contains("albumImage"){
    //            fileName.replacingOccurrences(of: "albumImage", with: "")
    //        }else{fileName}
    //    }
    //    func saveToDocument(fileNames: [String]) async{
    //        await withThrowingTaskGroup(of: Void.self) {[weak self] group in
    //            for fileName in fileNames {
    //                group.addTask{[weak self] in
    //                    await self?.saveToDocument(fileName: fileName)
    //                }
    //            }
    //        }
    //    }
}