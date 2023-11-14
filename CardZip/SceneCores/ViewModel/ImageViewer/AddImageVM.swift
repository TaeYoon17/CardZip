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
final class AddImageVM: ImageViewerVM{
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
//        print("NewFileNames:",newFileNames)
//        print("DeleteFileNames",deleteFileNames)
//        print("appendFileNames",appendFileNames)
        Task{
            await appendFileNames.asyncForEach {
                await repository.update(item: ImageItem(name: $0, count: 0))
                await ircSnapShot?.plusCount(id: $0)
            }
            Task.detached {[weak self] in
                await deleteFileNames.asyncForEach { await self?.ircSnapShot?.minusCount(id: $0) }
            }
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
    func saveRepository(){
        
    }
}
