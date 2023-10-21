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
    var pinnedRegistration: UICollectionView.CellRegistration<PinnedSetCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let item = self?.pinnedItemStore.fetchByID(itemIdentifier.id) else { return}
            cell.backgroundColor = .lightBg
            cell.pinType = item.type
            cell.setItem = item.setItem
            if let imagePath = item.setItem?.imagePath{
                Task{
                    cell.image = await UIImage.fetchBy(identifier: imagePath)
                }
            }else{
                cell.image = nil
            }
        }
    }
    var folderListItemRegistration : UICollectionView.CellRegistration<DisclosureItemCell,Item>{
        UICollectionView.CellRegistration{ cell, indexPath, itemIdentifier in
            let item = self.folderItemStore.fetchByID(itemIdentifier.id)
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
            guard let sectionType = SectionType(rawValue: indexPath.section) else {return}
            switch sectionType{
            case .folderList:
                supplementaryView.tapped = {[weak self] val in
                    self?.isExist = val
                }
            default: break
            }
        }
    }
    var setListHeaderRegistration: UICollectionView.SupplementaryRegistration<HeaderReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "setListHeaderRegi") { supplementaryView, elementKind, indexPath in
            guard let sectionType = SectionType(rawValue: indexPath.section) else {return}
            switch sectionType{
            case .setList:
                print("setListHeaderRegistration","Ssets".localized,"MainSets".localized,"MainFolders".localized)
                supplementaryView.title = sectionType.title
                supplementaryView.tapAction = {[weak self] in
                    let vc = SetListVC()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            default: break
            }
        }
    }
    var layoutHeaderRegistration:  UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutHeader") { supplementaryView, elementKind, indexPath in }
    }
}
