//
//  AddImageVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import UIKit
extension AddImageVC{
    func collectionViewConfig(){
        collectionView.backgroundColor = .bg
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        let registration = imageRegistration
        let addRegistration = addRegistration
        dataSource = UICollectionViewDiffableDataSource<Section,String>(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            if itemIdentifier == "addBtn"{
                return collectionView.dequeueConfiguredReusableCell(using: addRegistration, for: indexPath, item: itemIdentifier)
            }else{
                let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
                cell.deleteAction = { [weak self] in
                    let actionSheet = CustomAlertController(actionList: [
                        .init(title: "Delete".localized, systemName: "trash", completion: {[weak self] in
                            self?.vm.deleteSelection(id: itemIdentifier)
                            self?.deleteCell(item: itemIdentifier)
                        })])
                    self?.present(actionSheet, animated: true)
                }
                return cell
            }
        })
    }
}
