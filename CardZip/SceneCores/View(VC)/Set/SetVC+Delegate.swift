//
//  SetVC+Delegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import SnapKit
import UIKit
import Combine
extension SetVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAction(startNumber: indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func selectAction(startNumber: Int = 0){
        let vc = CardVC()
        vc.setItem = setItem
        vc.studyType = vm.studyType
        vc.startCardNumber = startNumber
        vc.passthorughCompletion.sink { [weak self]  in
            guard let self else {return}
                self.initModel()
                switch self.vm.studyType{
                case .basic,.random: self.initDataSource()
                case .check: self.initCheckedDataSource()
            }
        }.store(in: &subscription)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
}
