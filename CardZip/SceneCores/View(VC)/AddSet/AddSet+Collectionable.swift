//
//  AddSet+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
extension AddSetVC:Collectionable,UICollectionViewDelegate{
    func configureCollectionView() {
        collectionView.backgroundColor = .bg
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
        //MARK: -- Registration 설정
        let layoutHeaderRegi = layoutHeaderRegistration
        let layoutFooterRegi = layoutFooterRegistration
        let editCellRegi = setCardRegistration
        let headerCellRegi = setHeaderRegistration
        let itemHeaderReigi = cellItemHeaderRegistration
//        guard let vm else {return}
        dataSource = DataSource(vm:vm,collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier.type{
            case .cards:
                let cell:AddSetVC.AddSetItemCell = collectionView.dequeueConfiguredReusableCell(using: editCellRegi, for: indexPath, item: itemIdentifier)
                return cell
            case .header:
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegi, for: indexPath, item: itemIdentifier)
                return cell
            }
       })
        dataSource.supplementaryViewProvider = {[weak self]collectionView, kind, indexPath in
            guard let self else {return nil}
            switch kind{
            case "LayoutHeader":
                return collectionView.dequeueConfiguredReusableSupplementary(using: layoutHeaderRegi, for: indexPath)
            case "LayoutFooter":
                return collectionView.dequeueConfiguredReusableSupplementary(using: layoutFooterRegi, for: indexPath)
            case UICollectionView.elementKindSectionHeader:
                let header =  collectionView.dequeueConfiguredReusableSupplementary(using: itemHeaderReigi, for: indexPath)
                header.count = vm.nowItemsCount
                return header
            default: return nil
            }
        }
    }
}
//MARK: -- UICollectionViewLayout
extension AddSetVC{
    var layout: UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {[weak self] idx, environment in
            let type = SectionType(rawValue: idx)!
            switch type{
            case .cards:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] action, sourceView, actionPerformed in
                        self?.dataSource.deleteItem(indexPath: indexPath)
                    }
                    deleteAction.image = UIImage(systemName: "trash")
                    return .init(actions: [deleteAction])
                }
                listConfig.showsSeparators = false
                listConfig.backgroundColor = .bg
                
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
                section.interGroupSpacing = 16
                let header : NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                header.pinToVisibleBounds = true
                header.zIndex = Int.max
                section.boundarySupplementaryItems = [header]
                return section
            case .header:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
                section.interGroupSpacing = 16
                return section
            }
        })
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(0)), elementKind: "LayoutHeader", alignment: .top),
                                                   .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)),elementKind: "LayoutFooter",alignment: .bottom)]
        layout.configuration = layoutConfig
        
        return layout
    }
}
