//
//  MainVC+CollectionDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit
extension MainVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer{collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item.type{
        case .folderList:
            let vc = SetListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case .pinned:
//            let setItem = self.pinnedItemStore.fetchByID(item.id).setItem
            let setItem = dataSource.pinnedItemStore.fetchByID(item.id).setItem
            let vc = SetVC()
            vc.setItem = setItem
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}
