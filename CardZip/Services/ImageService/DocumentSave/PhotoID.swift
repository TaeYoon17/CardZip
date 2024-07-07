//
//  PhotoIDtoDocuments.swift
//  CardZip
//
//  Created by 김태윤 on 12/7/23.
//
import UIKit
import Photos
import PhotosUI
import Combine
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
