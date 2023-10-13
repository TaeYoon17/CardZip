//
//  AddImageVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
import Photos
//MARK: -- CELL REGISTRATION
extension AddImageVC{
    var imageRegistration:UICollectionView.CellRegistration<ImageCell,String>{
        UICollectionView.CellRegistration<ImageCell,String> {[weak self] cell, indexPath, itemIdentifier in
//            if cell.image == nil{
//                Task{[weak self] in
//                    let image = await self?.displayImage(identifier: itemIdentifier)
//                    cell.image = image
//                }
//            }
            cell.image = self?.selection[itemIdentifier]
            cell.deleteAction = { [weak self] in
                let actionSheet = CustomAlertController(actionList: [
                    .init(title: "Delete", systemName: "trash", completion: {
                        print("삭제 버튼 탭탭탭")
                    })])
                self?.present(actionSheet, animated: true)
            }
        }
    }
    var addRegistration: UICollectionView.CellRegistration<AddItemCell,String>{
        UICollectionView.CellRegistration{ cell, indexPath, itemIdentifier in
            cell.action = { [weak self] in
                let actionSheet = CustomAlertController(actionList: [
                    .init(title: "Library",
                          systemName:  "folder.badge.plus",
                          completion: {[weak self] in
                              //                        print("하이욤")
                              guard let self else {return}
                              let snapshot = dataSource.snapshot()
                              var items = snapshot.itemIdentifiers(inSection: .main)
                              _ = items.popLast()
                              photoService.presentPicker(vc:self,multipleSelection: true,prevIdentifiers: items)
                          }),
                    .init(title: "Search", systemName: "magnifyingglass", completion: { [weak self] in
                        print("구글 검색")
                    }),
                    .init(title: "Camera", systemName: "camera", completion: { [weak self] in
                        print("카메라")
                    })
                ])
                self?.present(actionSheet, animated: true)
            }
        }
    }
}
