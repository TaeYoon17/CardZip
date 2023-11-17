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
    var updatedIRC = PassthroughSubject<[FileModel],Never>()
    weak var vc: UIViewController!
    override init(cardItem: CardItem, setName: String){
        super.init(cardItem: cardItem, setName: setName)
        photoService.passthroughIdentifiers.sink { [weak self] (collections,vc) in
            guard let self,vc == self.vc else {return}
            self.albumSelectionUpdate(ids:collections)
        }.store(in: &subscription)
    }
    deinit{
        ImageService.shared.resetCache(type: .file)
    }
    func albumSelectionUpdate(ids: [String]){
        passthoroughLoading.send(true)
        let newFileNames = ids.map{$0.getLocalPathName(type: .photo)}
        let deleteFileNames = self.selectedItems.subtracting(newFileNames).filter{$0.checkFilepath(type: .photo)}
        let appendFileNames = Set(newFileNames).subtracting(selectedItems)
        Task{ // 앨범 이미지 전부 앱 샌드박스에 저장
            await ImageService.shared.saveToDocumentBy(photoIDs:appendFileNames.map{
                $0.extractID(type: .photo)
            })
            passthoroughLoading.send(false)
            self.selectedItems = selectedItems.subtracting(deleteFileNames).union(appendFileNames)
        }
        Task{ await updateValues(appends:appendFileNames,deletes:deleteFileNames) }
    }
    func searchSelectionUpdate(ids:[String]){
        passthoroughLoading.send(true)
        let newItems = ids.enumerated().map { ($1.getLocalPathName(type: .search),$0) }
        let dict = newItems.reduce(into: [:]) { $0[$1.0] = $1.1 }
        let newFileNames = newItems.map{$0.0}
        // 여기에 존재하지 않았던 아이템들만 빼기 (중복되지 않은)
        let appendFileNames = Array(Set(newFileNames).subtracting(selectedItems))
        let downloadURLs = appendFileNames.compactMap { dict[$0] }.map{ids[$0]}
        Task{
            await ImageService.shared.saveToDocumentBy(searchURLs: downloadURLs,fileNames: appendFileNames)
            passthoroughLoading.send(false)
            self.selectedItems = selectedItems.union(appendFileNames)
        }
        Task{ await updateValues(appends:appendFileNames,deletes:[]) } // 이 카드 세트에 중복되지 않은 파일들만 업데이트
    }
    func deleteSelection(id:String){
        self.selectedItems.remove(id)
        Task{
            await ircSnapShot.minusCount(id: id)
        }
    }
    func updateValues(appends: any Sequence<String>,deletes:any Sequence<String>) async {
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
        let albumImagePathes = self.selectedItems
            .filter { $0.checkFilepath(type: .photo)}
            .map{$0.extractID(type: .photo)}
        photoService.presentPicker(vc: vc,
                                   multipleSelection: true,
                                   prevIdentifiers: albumImagePathes)
    }
}
