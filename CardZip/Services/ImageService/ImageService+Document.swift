//
//  ImageService+Document.swift
//  CardZip
//
//  Created by 김태윤 on 12/5/23.
//

import UIKit
import Photos
import PhotosUI
extension ImageService{
    // UIImage로 변환 가능, 문서 폴더에 없는 이미지들만 필터링
    func getDownloadTarget(results: [PHPickerResult])->[PHPickerResult]{
        return results.filter{ $0.itemProvider.canLoadObject(ofClass: UIImage.self)
        }.filter{!FileManager.checkExistDocument(fileName: $0.assetIdentifier!.getLocalPathName(type: .photo), type: .jpg)}
    }
    func saveToDocumentBy(result:PHPickerResult)async throws{
        let item = result.itemProvider
        let image = try await item.loadimage()
        let fileName = result.assetIdentifier!.getLocalPathName(type: .photo)
        image?.saveToDocument(fileName: fileName)
    }
}
//MARK: -- 이미지 다운로드 - 앨범 아이디
extension ImageService{
    func saveToDocumentBy(photoID: String) async {
        let image = try? await UIImage.fetchBy(identifier: photoID)
        if !FileManager.checkExistDocument(fileName: photoID.getLocalPathName(type: .photo), type: .jpg){
            image?.saveToDocument(fileName: photoID.getLocalPathName(type: .photo))
        }
    }
    //[String] -> 배열에서 Set도 가능하게 확장
    func saveToDocumentBy(photoIDs: any Collection<String>) async throws{
        try await withThrowingTaskGroup(of: Void.self) {[weak self] group in
            for photoID in photoIDs {
                group.addTask{[weak self] in
                    await self?.saveToDocumentBy(photoID: photoID)
                }
            }
        }
    }
}
//MARK: -- SaveToDocument - 네트워크 이미지
extension ImageService{
    func saveToDocumentBy(searchURL: String,fileName:String) async{
        let image = try? await UIImage.fetchBy(link: searchURL)
        if !FileManager.checkExistDocument(fileName: fileName, type: .jpg){
            image?.saveToDocument(fileName: searchURL.getLocalPathName(type: .search))
        }
    }
    func saveToDocumentBy(searchURLs:[String],fileNames:[String]) async throws{
        try await withThrowingTaskGroup(of: Void.self) {[weak self] group in
            for (searchURL,fileName) in zip(searchURLs,fileNames) {
                group.addTask{[weak self] in
                    await self?.saveToDocumentBy(searchURL: searchURL,fileName: fileName)
                }
            }
            try await group.waitForAll()
        }
    }
}
