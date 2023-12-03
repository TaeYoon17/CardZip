//
//  AddSet+Registrations.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
import SnapKit
// MARK: -- CELL REGISTRATION
extension AddSetVC{
    var setCardRegistration: UICollectionView.CellRegistration<AddSetItemCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let cardItem = self?.dataSource.itemModel.fetchByID(itemIdentifier.id) else {return}
            // 초기화시 설정할 의미 및 뜻
            let cellVM = AddSetItemCellVM(addSetVM: self?.vm, cardItem: cardItem)
            cell.vm = cellVM
            cell.fieldAccessoryView = self?.appendItemView
        }
    }
    var setHeaderRegistration: UICollectionView.CellRegistration<AddSetCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let headerItem = self?.dataSource.headerModel.fetchByID(itemIdentifier.id) else {return}
            let vm = AddSetHeaderVM(addSetVM: self?.vm, setItem: headerItem)
            cell.vm = vm
            guard let imagePath = headerItem.imagePath else { return }
            Task{
                try await ImageService.shared.appendCache(type:.file,name:imagePath,size:.init(width: 720, height: 720))
            }
        }
    }
    private var appendItemView: UIView {
        let view = NavBarView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        view.alpha = 1
        let btn = BottomImageBtn(systemName: "plus")
        let doneBtn = UIButton(configuration: .plain())
        doneBtn.setAttributedTitle(.init(string: "Done".localized, attributes: [
            .font : UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]), for: .normal)
        doneBtn.tintColor = .cardPrimary
        btn.configuration?.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        btn.addAction(.init(handler: { [weak self] _ in
            self?.dataSource.createItem()
            Task{ self?.collectionView.scrollToLastItem() }
        }), for: .touchUpInside)
        doneBtn.addAction(.init(handler: { [weak self] _ in
            self?.view.endEditing(true)
        }), for: .touchUpInside)
        view.addSubview(btn)
        view.addSubview(doneBtn)
        btn.snp.makeConstraints { $0.center.equalToSuperview() }
        doneBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16.5)
            make.centerY.equalToSuperview()
        }
        return view
    }
}

//MARK: -- SUPPLEMENT REGISTRATION
extension AddSetVC{
    var layoutHeaderRegistration: UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutHeader") { supplementaryView,elementKind,indexPath in }
    }
    var layoutFooterRegistration: UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutFooter") { supplementaryView,elementKind,indexPath in }
    }
    
    var cellItemHeaderRegistration: UICollectionView.SupplementaryRegistration<AddSetItemHeader>{
        UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) {[weak self] supplementaryView,elementKind,indexPath in
            supplementaryView.title = "Cards"
            supplementaryView.vm = self?.vm
        }
    }
}
