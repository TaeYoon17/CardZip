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
        UICollectionView.CellRegistration{ cell, indexPath, itemIdentifier in
        guard let cardItem = self.cardModel.fetchByID(itemIdentifier.id) else {return}
        cell.term = cardItem.title
        cell.mainDescription = cardItem.description
        }
    }
}
extension SetVC{
    var setHeaderReusable:UICollectionView.SupplementaryRegistration<TopHeaderReusableView>{
        UICollectionView.SupplementaryRegistration<TopHeaderReusableView>(elementKind: "LayoutHeader") { supplementaryView, elementKind, indexPath in
            guard let sectionType = SectionType(rawValue: indexPath.section),
                  let setItem = self.setItem else {return}
            switch sectionType{
            case .main:
                supplementaryView.collectionTitle = setItem.title
                supplementaryView.collectionDescription = setItem.setDescription
                if let imagePath = setItem.imagePath{
                    Task{
                        print("SetVC ImagePath",imagePath)
                        supplementaryView.image = await .fetchBy(identifier: imagePath)
                    }
                }
            }
            
        }
    }
}
