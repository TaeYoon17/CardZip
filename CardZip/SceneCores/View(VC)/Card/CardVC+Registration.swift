//
//  CardVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import UIKit
import SnapKit
extension CardVC{
    var cellRegistration:UICollectionView.CellRegistration<CardCell,CardItem.ID>{ 
        UICollectionView.CellRegistration{[weak self] cell, indexPath, itemIdentifier in
            guard let cardItem = self?.cardsModel.fetchByID(itemIdentifier) else {return}
            cell.cardItem = cardItem
        }
    }
}
