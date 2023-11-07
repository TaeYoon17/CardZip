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
    weak var vc: UIViewController!
    override init(cardItem: CardItem, setName: String){
        super.init(cardItem: cardItem, setName: setName)
        photoService.passthroughIdentifiers.sink { [weak self] (collections,vc) in
            guard let self,vc == self.vc else {return}
            Task{
                await self.selectionUpdate(ids:collections)
            }
        }.store(in: &subscription)
    }
    @MainActor func selectionUpdate(ids: [String]){
        let ids = ids.map{"albumImage\($0)"}.map{$0.replacingOccurrences(of: "/", with: "_")}
        let deleteItems = self.selectedItems
            .subtracting(ids)
            .filter{$0.contains("albumImage")}
        let appendItems = Set(ids).subtracting(selectedItems)
        Task{ // 앨범 이미지 전부 앱 샌드박스에 저장
            await ImageService.shared.saveToDocumentBy(photoIDs:appendItems.map{$0.replacingOccurrences(of: "albumImage", with: "")})
        }
        repository?.createImageTables(fileNames: Array(appendItems))
        repository?.plusCntImageTables(fileNames: Array(appendItems))
        repository?.minusCntImageTables(fileNames: Array(deleteItems))
        self.selectedItems = selectedItems.subtracting(deleteItems).union(appendItems)
    }
    func presentPicker(vc: UIViewController){
//        현재 다운받은 이미지에서 앨범에 존재하는 이미지를 추출해야한다.
        self.vc = vc
        let albumImagePathes = self.selectedItems.filter { imagePath in
            imagePath.contains("albumImage")
        }.map{
            $0.replacingOccurrences(of: "albumImage", with: "").replacingOccurrences(of: "_", with: "/")
        }
        photoService.presentPicker(vc: vc,
                                   multipleSelection: true,
                                   prevIdentifiers: albumImagePathes)
    }
}
