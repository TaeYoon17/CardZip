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
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item.type{
        case .folderList:
            let vc = SetListVC()
            self.navigationController?.pushViewController(vc, animated: true)
            collectionView.deselectItem(at: indexPath, animated: true)
        case .pinned:
            let setItem = self.pinnedItemStore.fetchByID(item.id).setItem
            let vc = SetVC()
            vc.setItem = setItem
            self.navigationController?.pushViewController(vc, animated: true)
            collectionView.deselectItem(at: indexPath, animated: true)
        default: break
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) { }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let nowY = scrollView.contentOffset.y
        self.isNavigationShow = nowY > 60
    }
}
