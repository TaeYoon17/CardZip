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
        let newPhotoFileNames = ids.map { $0.getLocalPathName(type: .photo) }
        let appendFileNames = Array(Set(newPhotoFileNames).subtracting(selectedItems))
        Task{
            passthoroughLoading.send(false)
            self.selectedItems = selectedItems.union(newPhotoFileNames)
            await updateImageRC(appends:appendFileNames,deletes:[])
        }
    }
    
    func searchSelectionUpdate(ids:[String]){ // 특정 서비스[ex: A 채팅방]에서 사용할 이미지 아이디들
        // 인터넷 URL 기반으로 로컬 이미지 이름 만들기
        let newItems = ids.enumerated().map { ($1.getLocalPathName(type: .search),$0) }
        let dict = newItems.reduce(into: [:]) { $0[$1.0] = $1.1 }
        let newFileNames = newItems.map{$0.0}
        // 기존에 존재한 이미지들을 제외하고 새로 로컬에 저장할 이미지들 (다른 서비스[ex: B 채팅방]에서는 사용하고 있을 가능성이 있다.)
        let appendFileNames = Array(Set(newFileNames).subtracting(selectedItems))
        // 새로 로컬에 저장할 이미지들의 원래 존재한 인터넷 URL 가져오기
        let downloadURLs = appendFileNames.compactMap { dict[$0] }.map{ids[$0]}
        Task{
            // 만약 로컬이 이미지 이름이 없으면 이미지 다운로드, 있으면 로컬에서 가져온다.
            try await ImageService.shared.saveToDocumentBy(searchURLs: downloadURLs,fileNames: appendFileNames)
            passthoroughLoading.send(false)
            // 특정 서비스[ex: A 채팅방]에 기존에 사용하는 로컬 이미지들과 새로 다운받은 로컬 이미지들을 합치기
            self.selectedItems = selectedItems.union(appendFileNames)
            // 특정 서비스[ex: A 채팅방]에 새로 추가한 이미지들 ImageRCM 업데이트
            await updateImageRC(appends:appendFileNames,deletes:[])
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
    func deleteSelection(id:String){
        self.selectedItems.remove(id)
        Task{
            await ircSnapShot.minusCount(id: id)
        }
    }
    func presentPicker(vc: UIViewController){
//        현재 다운받은 이미지에서 앨범에 존재하는 이미지를 추출해야한다.
        self.vc = vc
        photoService.presentPicker(vc: vc,maxSelection: 10 - self.selectedItems.count)
        passthoroughLoading.send(true)
    }
}
