//
//  PHResults.swift
//  CardZip
//
//  Created by 김태윤 on 12/7/23.
//
import UIKit
import Photos
import PhotosUI
import Combine
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

