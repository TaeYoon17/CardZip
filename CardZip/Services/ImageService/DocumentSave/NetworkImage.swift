//
//  NetworkImage.swift
//  CardZip
//
//  Created by 김태윤 on 12/7/23.
//
import UIKit
import Photos
import PhotosUI
import Combine
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
