//
//  ShowImageVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import SnapKit
import UIKit
import Photos
//MARK: -- CELL REGISTRATION
extension ShowImageVC{
    var imageRegistration:UICollectionView.CellRegistration<ImageCell,String>{
        UICollectionView.CellRegistration<ImageCell,String> {[weak self] cell, indexPath, itemIdentifier in
            cell.image = self?.selection[itemIdentifier]
        }
    }
}
