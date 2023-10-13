//
//  SetVC+Delegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import SnapKit
import UIKit
extension SetVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CardVC()
        guard let setItem else {return}
        vc.setItem = setItem
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
