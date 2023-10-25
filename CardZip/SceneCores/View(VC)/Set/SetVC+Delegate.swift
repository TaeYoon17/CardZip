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
//        switch vm.studyType{
//        case .basic:
//            if let item = dataSource.itemIdentifier(for: indexPath){
//
//            }
//        case .check: selectAction(startNumber: indexPath.row)
//        case .random: selectAction()
//        }
//        selectAction()
        if let item = dataSource.itemIdentifier(for: indexPath){
            selectAction(cardItem: item)
        }else{
            selectAction()
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func selectAction(startNumber: Int = 0){
        print(#function)
        let vc = CardVC()
        let cardVM = CardVM()
        cardVM.setItem = setItem
        cardVM.studyType = vm.studyType
        cardVM.startCardNumber = startNumber
        vc.vm = cardVM
        vc.passthorughCompletion.sink { [weak self]  in
            guard let self else {return}
                self.initModel()
            Task{
                var snapshot: Snapshot
                switch self.vm.studyType{
                case .basic,.random: snapshot = try await self.initDataSource()
                case .check: snapshot = try await self.initCheckedDataSource()
                }
                await self.dataSource.apply(snapshot,animatingDifferences: true)
            }
        }.store(in: &subscription)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    func selectAction(cardItem: Item){
        print(#function)
        let vc = CardVC()
        let cardVM = CardVM()
        vc.vm = cardVM
        cardVM.setItem = setItem
        cardVM.studyType = vm.studyType
        cardVM.startItem = cardModel?.fetchByID(cardItem.id)
        vc.passthorughCompletion.sink { [weak self]  in
            guard let self else {return}
                self.initModel()
            Task{
                var snapshot:Snapshot
                switch self.vm.studyType{
                case .basic,.random: snapshot = try await self.initDataSource()
                case .check: snapshot = try await self.initCheckedDataSource()
                }
                await self.dataSource.apply(snapshot,animatingDifferences: true)
            }
        }.store(in: &subscription)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
}
