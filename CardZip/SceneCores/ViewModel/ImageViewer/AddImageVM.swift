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
    var photoService = PhotoService.shared
    var passthorughImgID = PassthroughSubject<[String],Never>()
    @MainActor func selectionUpdate(ids: [String]) async{
        self.selection = ids
    }
    override init(){
        super.init()
        photoService.passthroughIdentifiers.sink { [weak self] (collections,vc) in
            guard let self else {return}
            Task{
                await self.selectionUpdate(ids:collections)
//                self.updateSnapshot(result: collections)
            }
        }.store(in: &subscription)
    }
    @MainActor func selectionUpdate(ids: [String]){
        let deleteItems = Set(selection).subtracting(ids)
        let appendItems = Set(ids).subtracting(selection)
        var newSelection = Set(selection)
        deleteItems.forEach {
            guard let dbkey = cardItem?.dbKey else {return}
            repository?.removeBusinessTable(key: dbkey, imagePath: $0)
            newSelection.remove($0)
        }
        appendItems.forEach{ newSelection.insert($0) }
        selection = Array(newSelection)
    }
}
