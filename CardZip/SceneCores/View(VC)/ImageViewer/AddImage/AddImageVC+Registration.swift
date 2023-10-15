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
    var imageRegistration:UICollectionView.CellRegistration<DeletableImageCell,String>{
        UICollectionView.CellRegistration<DeletableImageCell,String> {[weak self] cell, indexPath, itemIdentifier in
            cell.image = self?.selection[itemIdentifier]
            
        }
    }
    var addRegistration: UICollectionView.CellRegistration<AddItemCell,String>{
        UICollectionView.CellRegistration{[weak self] cell, indexPath, itemIdentifier in
            cell.action = { [weak self] in
                let actionSheet = CustomAlertController(actionList: [
                    .init(title: "Library",
                          systemName:  "folder.badge.plus",
                          completion: {[weak self] in
                              guard let self else {return}
                              photoService.presentPicker(vc: self,multipleSelection: true,prevIdentifiers: getCurrentImageIds())
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
