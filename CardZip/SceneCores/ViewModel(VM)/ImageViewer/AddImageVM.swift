//
//  ImageAddVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import Photos
import PhotosUI
import Combine
import RealmSwift
final class AddImageVM: ImageViewerVM,ImageSearchDelegate{
    var ircSnapShot: ImageRC.SnapShot!
    var photoService = PhotoService.shared
    var passthorughImgID = PassthroughSubject<([String],ImageRC.SnapShot),Never>()
    var passthoroughLoading = PassthroughSubject<Bool,Never>()
    var passthroughProgress = PassthroughSubject<Float,Never>()
    var updatedIRC = PassthroughSubject<[FileModel],Never>()
    weak var vc: UIViewController!
    override init(cardItem: CardItem, setName: String){
        super.init(cardItem: cardItem, setName: setName)
        photoService.passthroughIdentifiers.sink { [weak self] (collections,vc) in
            guard let self,vc == self.vc else {return}
            self.albumSelectionUpdate(ids:collections)
        }.store(in: &subscription)
        Task{
            await photoService.counter.progress.sink {[weak self] (count,max) in
                let max = max == 0 ? 1 : max
                self?.passthroughProgress.send(Float(count) / Float(max))
            }.store(in: &subscription)
        }
    }
    deinit{
        ImageService.shared.resetCache(type: .file)
    }
    func albumSelectionUpdate(ids: [String]){
        let newPhotoFileNames = ids.map { $0.getLocalPathName(type: .photo) }
        let appendFileNames = Array(Set(newPhotoFileNames).subtracting(selectedItems))
        Task{
            passthoroughLoading.send(false)
            self.selectedItems = selectedItems.union(newPhotoFileNames)
            await updateImageRC(appends:appendFileNames,deletes:[])
        }
    }
    func searchSelectionUpdate(ids:[String]){
        let newItems = ids.enumerated().map { ($1.getLocalPathName(type: .search),$0) }
        let dict = newItems.reduce(into: [:]) { $0[$1.0] = $1.1 }
        let newFileNames = newItems.map{$0.0}
        // 여기에 존재하지 않았던 아이템들만 빼기 (중복되지 않은)
        let appendFileNames = Array(Set(newFileNames).subtracting(selectedItems))
        let downloadURLs = appendFileNames.compactMap { dict[$0] }.map{ids[$0]}
        Task{
            try await ImageService.shared.saveToDocumentBy(searchURLs: downloadURLs,fileNames: appendFileNames)
            passthoroughLoading.send(false)
            self.selectedItems = selectedItems.union(appendFileNames)
            await updateImageRC(appends:appendFileNames,deletes:[])
        }
    }
    func deleteSelection(id:String){
        self.selectedItems.remove(id)
        Task{
            await ircSnapShot.minusCount(id: id)
        }
    }
    func updateImageRC(appends: any Sequence<String>,deletes:any Sequence<String>) async {
        await appends.asyncForEach {
            if !ircSnapShot.existItem(id: $0){
                await repository.insert(item: ImageItem(name: $0, count: 0))
            }
            await ircSnapShot?.plusCount(id: $0)
        }
        Task.detached {[weak self ] in
            await deletes.asyncForEach { await self?.ircSnapShot?.minusCount(id: $0) }
        }
    }
    
    func presentPicker(vc: UIViewController){
//        현재 다운받은 이미지에서 앨범에 존재하는 이미지를 추출해야한다.
        self.vc = vc
        photoService.presentPicker(vc: vc,maxSelection: 10 - self.selectedItems.count)
        passthoroughLoading.send(true)
    }
}
