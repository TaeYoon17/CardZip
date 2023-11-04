//
//  ImageSearchVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import UIKit
import SnapKit
extension ImageSearchVC{
    var searchImageCellRegistration: UICollectionView.CellRegistration<ImageSearchItemCell,ImageSearch.ID>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self,let item = dataSource.fetchItem(id: itemIdentifier) else {return}
            cell.model = item
            if item.isCheck{
                cell.selectNumber = self.vm.getItemCount(item)
            }
        }
    }
}
