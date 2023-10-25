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
            guard let self,let cardItem = dataSource.cardsModel.fetchByID(itemIdentifier) else {return}
            cell.vm = CardCellVM(cardVM: vm, cardItem: cardItem)
        }
    }
}

