//
//  SetVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import UIKit
//MARK: -- CELL REGISTRATION
extension SetVC{
    var cardListRegistration:UICollectionView.CellRegistration<SetCardListCell,Item> {
        UICollectionView.CellRegistration{[weak self] cell, indexPath, itemIdentifier in
            guard let cardItem = self?.cardModel?.fetchByID(itemIdentifier.id) else {return}
            cell.term = cardItem.title
            cell.mainDescription = cardItem.definition
            cell.isLike = cardItem.isLike
            cell.isCheck = cardItem.isChecked
            cell.isSpeaker = false
        }
    }
}
extension SetVC{
    var setHeaderReusable:UICollectionView.SupplementaryRegistration<TopHeaderReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutHeader") {[weak self] supplementaryView, elementKind, indexPath in
            guard let sectionType = SectionType(rawValue: indexPath.section),
                  let setItem = self?.setItem else {
                supplementaryView.playBtn.alpha = 0
                return
            }
            Task{
                if setItem.cardCount == 0{
                    supplementaryView.playBtn.alpha = 0
                }else {
                    supplementaryView.playBtn.alpha = 1
                }
            }
            switch sectionType{
            case .main:
                supplementaryView.collectionTitle = setItem.title
                supplementaryView.collectionDescription = setItem.setDescription
                Task{
                    if let imagePath = setItem.imagePath{
                        if  let image = await UIImage.fetchBy(identifier: imagePath,ofSize: .init(width: 600, height: 600)){
                            supplementaryView.image = image
                            supplementaryView.errorMessage = ""
                        }else{
                            supplementaryView.image = .init(systemName: "questionmark.circle", ofSize: 88, weight: .medium)
                            supplementaryView.errorMessage = "Image not found"
                        }
                    }else{
                        supplementaryView.image = .init(systemName: "questionmark.circle", ofSize: 88, weight: .medium)
                        supplementaryView.errorMessage = "Empty Image"
                    }
                }
            }
            
        }
    }
    var setCardHeaderReusable: UICollectionView.SupplementaryRegistration<SetCardListHeader>{
        UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader){[weak self] supplementaryView, elementKind, indexPath in
            guard let self else {return}
            supplementaryView.vm = vm
        }
    }
}
