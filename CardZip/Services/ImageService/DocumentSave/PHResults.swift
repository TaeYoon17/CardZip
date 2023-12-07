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
//    func saveToDocumentBy(results: [PHPickerResult],counter: TaskCounter? = nil) async throws{
//        subscription.removeAll()
//        let imageResults = ImageService.shared.getDownloadTarget(results: results)
//        await counter?.changeMax(imageResults.count)
//        await counter?.reset()
//        try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
//            guard let self else {return}
//            for result in imageResults{
//                group.addTask {
//                    do{
//                        try await self.saveToDocumentBy(result: result)
//                        await counter?.increment()
//                    }catch{
//                        await counter?.failed()
//                    }
//                }
//            }
//            await counter?.sink(receiveValue: {[group] val in
//                if !val{ group.cancelAll() }
//            }).store(in: &subscription)
//            try await group.waitForAll()
//        }
//    }
    
}

