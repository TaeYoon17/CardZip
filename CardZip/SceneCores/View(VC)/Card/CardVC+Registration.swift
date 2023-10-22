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
            guard let self,let cardItem = cardsModel.fetchByID(itemIdentifier) else {return}
            cell.cardItem = cardItem
            cell.cardVM = vm
            cell.vm = CardCellVM(cardVM: vm, item: cardItem)
        }
    }
}

