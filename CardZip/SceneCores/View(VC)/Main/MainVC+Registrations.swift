//
//  MainVC+CellRegistrations.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit
//MARK: -- CELL REGISTRATION
extension MainVC{
    var pinnedRegistration: UICollectionView.CellRegistration<PinnedSetCell,Item.ID>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.backgroundColor = .lightBg
            cell.pinType = .heart
        }
    }
    var folderListItemRegistration : UICollectionView.CellRegistration<DisclosureItemCell,Item.ID>{
        UICollectionView.CellRegistration{ cell, indexPath, itemIdentifier in
            let item = self.folderItemStore.fetchByID(itemIdentifier)
//            cell.titleLabel.text = item?.title
            cell.title = item?.title
            cell.setNumber = item?.setNumber ?? 0
        }
    }
}

//MARK: -- SUPPLEMENT REGISTRATION
extension MainVC{
    var folderHeaderRegistration: UICollectionView.SupplementaryRegistration<DisclosureHeader>{
        UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let sectionType = Section.Identifier(rawValue: indexPath.section) else {return}
            switch sectionType{
            case .folderList:
                supplementaryView.tapped = {[weak self] val in
                    self?.isExist = val
                }
            default: break
            }
        }
    }
    var layoutHeaderRegistration:  UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutHeader") { supplementaryView, elementKind, indexPath in }
    }
}
