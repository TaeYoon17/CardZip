//
//  AddSetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import Foundation
import Photos
import PhotosUI
import Combine
extension AddSetVM{
    enum CardActionType{ case imageTapped, delete }
    enum SetActionType{ case imageTapped }
}
final class AddSetVM:ImageSearchDelegate{
    deinit{
        Task.detached{
            ImageService.shared.resetCache(type: .search)
            ImageService.shared.resetCache(type: .album)
        }
        print("AddSetVM DEINIT!")
    }
    @MainActor let repository = CardSetRepository()
    @MainActor let cardRepository = CardRepository()
    weak var photoService:PhotoService! = PhotoService.shared
    @Published var dataProcess: DataProcessType
    @Published var nowItemsCount: Int = 0
    @DefaultsState(\.recentSet) var recentKey
    var ircSnapshot: ImageRC.SnapShot = ImageRC.shared.snapshot
    var setItem: SetItem?
    var subscription = Set<AnyCancellable>()
    
    weak var vc: UIViewController!
    // DataProcessTyppe Edit했을 때 변경 사항을 던져주는 passthrough
    var passthroughEditSet = PassthroughSubject<SetItem,Never>()
    var passthroughCloseAction = PassthroughSubject<Void,Never>() // 닫을 때
    var passthroughErrorMessage = PassthroughSubject<String,Never>() // 에러 메시지를 던질 때
    var updatedCardItem = PassthroughSubject<(CardItem,Bool),Never>() // 리스트에서 단일 카드 내용을 업데이트 할 때
    var updatedSetItem = PassthroughSubject<(SetItem,Bool),Never>() // 세트 정보를 업데이트 할 때
    // 카드에서 뷰컨 프로퍼티를 사용하는 액션을 요청할 때
    var cardAction = PassthroughSubject<(CardActionType,CardItem?),Never>()
    var setAction = PassthroughSubject<(SetActionType,SetItem?),Never>()
    init(dataProcess: DataProcessType,setItem: SetItem?){
        self.dataProcess = dataProcess
        switch dataProcess{
        case.add:
            self.setItem = .init(title: "", setDescription: "", cardList: [CardItem()], cardCount: 0)
        case .edit:
            self.setItem = setItem
        }
        bindPhPicker()
    }
    
    func bindPhPicker() {
        photoService.passthroughIdentifiers.sink {[weak self] val,vc in
            guard let self,self.vc == vc,let newAlbumID = val.first else {return}
            let newFileName = newAlbumID.getLocalPathName(type: .photo)
            let prevFileName = self.setItem?.imagePath
            self.setItem?.imagePath = newFileName
            Task{@MainActor [weak self] in
                guard let self else {return}
                if !self.ircSnapshot.existItem(id: newFileName){
                    await ImageService.shared.saveToDocumentBy(photoIDs:[newAlbumID])
//                    await IRC.shared.insertRepository(item: ImageItem(name: newFileName, count: 0))
                }
                if let setItem{ updatedSetItem.send((setItem,true)) }
                Task.detached {
                    await self.ircSnapshotUpdate(new: newFileName, prev: prevFileName)
                }
            }
        }.store(in: &subscription)
    }
    func searchSelectionUpdate(ids: [String]) {
        guard let newFileName = ids.first?.getLocalPathName(type: .search) else {
            passthroughErrorMessage.send("Don't accessible image")
            return
        }
        let prevFileName = self.setItem?.imagePath
        self.setItem?.imagePath = newFileName
        Task{@MainActor [weak self] in
            guard let self else {return}
            if !self.ircSnapshot.existItem(id: newFileName){
                await ImageService.shared.saveToDocumentBy(searchURLs: ids,fileNames: [newFileName])
                await IRC.shared.insertRepository(item: ImageItem(name: newFileName, count: 0))
            }
            if let setItem{ updatedSetItem.send((setItem,true)) }
            Task.detached {
                await self.ircSnapshotUpdate(new: newFileName, prev: prevFileName)
            }
        }
    }
    private func ircSnapshotUpdate(new:String,prev:String?) async {
        await ircSnapshot.plusCount(id: new)
        if let prev{
            await ircSnapshot.minusCount(id:prev)
        }
    }
    func presentPicker(vc: UIViewController){
//        현재 다운받은 이미지에서 앨범에 존재하는 이미지를 추출해야한다.
        self.vc = vc
        photoService.presentPicker(vc: vc,multipleSelection: false)
    }
}
