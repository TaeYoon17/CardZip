//
//  SettingVC+Delegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
extension SettingVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer{ collectionView.deselectItem(at: indexPath, animated: true) }
        guard let id = dataSource.itemIdentifier(for: indexPath),
              let vcItem = self.itemModel.fetchByID(id) else {return}
        vcItem.action?()
    }
}
