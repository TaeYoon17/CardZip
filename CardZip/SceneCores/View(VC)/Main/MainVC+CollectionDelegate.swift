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
        defer{
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item.type{
        case .folderList:
            let vc = SetListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case .pinned:
            //MARK: -- 아이템은 무조건 있어야함
            guard let setItem = dataSource.pinnedItemStore.fetchByID(item.id).setItem else {return}
            let vm = SetVM(setItem: setItem)
            let vc = SetVC()
            vc.vm = vm
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}
