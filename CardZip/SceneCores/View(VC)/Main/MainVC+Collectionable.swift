//
//  MainVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit
extension MainVC: Collectionable{
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .bg
        let folderItemRegi = folderListItemRegistration
        let folderHeaderRegi = folderHeaderRegistration
        let setListHeaderRegi = setListHeaderRegistration
        let pinnedItemRegi = pinnedRegistration
        let layoutHeaderRegi = layoutHeaderRegistration

        dataSource = MainDataSource(vm: vm,collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let sectionType = SectionType(rawValue: indexPath.section) else {return .init()}
            switch sectionType{
            case .setList:
                let cell = collectionView.dequeueConfiguredReusableCell(using: pinnedItemRegi, for: indexPath, item: itemIdentifier)
                return cell
            case .folderList:
                let cell = collectionView.dequeueConfiguredReusableCell(using: folderItemRegi, for: indexPath, item: itemIdentifier)
                return cell
            case .pinned:
                return collectionView.dequeueConfiguredReusableCell(using: pinnedItemRegi, for: indexPath, item: itemIdentifier)
            }
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionType = SectionType(rawValue: indexPath.section) else {
                fatalError("dㅣ게 안됨 ")
            }
            switch kind{
            case UICollectionView.elementKindSectionHeader:
                switch sectionType{
                case .folderList:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: folderHeaderRegi, for: indexPath)
                default: return nil
                }
            case "setListHeaderRegi":
                switch sectionType{
                case .setList:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: setListHeaderRegi, for: indexPath)
                default: return nil
                }
            case "LayoutHeader":
                return collectionView.dequeueConfiguredReusableSupplementary(using: layoutHeaderRegi, for: indexPath)
            default: return nil
            }
        }
    }
    
}

extension MainVC{
    var layout: UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout {[weak self] number , environment in
            guard let self else {fatalError("Don't use layout")}
            let sectionType = Section.ID(rawValue: number) ?? .folderList
            let section : NSCollectionLayoutSection
            switch sectionType{
            case .folderList:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44 )), subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: "folderListBg")
                section.decorationItems = [sectionBackgroundDecoration]
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
                section.contentInsets = .init(top: 0, leading: 32, bottom: self.isExist ? 20 : 0, trailing: 32)
            case .pinned:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(132)), subitems: [item] )
                group.contentInsets = .init(top: 0, leading: 8, bottom: 8, trailing: 8)
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                if UIScreen.main.bounds.width > 400{
                    section.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
                }else{
                    section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
                }
            case .setList:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.333)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(0)), subitems: [item,item,item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: "folderListBg")
                section.decorationItems = [sectionBackgroundDecoration]
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)), elementKind: "setListHeaderRegi", alignment: .top)]
                section.contentInsets = .init(top: 0, leading: 32, bottom: 0, trailing: 32)
            }
            return section
        }
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        
        let bottom: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .absolute(56)),
                                                                        elementKind: "LayoutHeader", alignment: .bottom)
        layoutConfig.boundarySupplementaryItems = [bottom]
        layoutConfig.interSectionSpacing = 16
        layout.configuration = layoutConfig
        layout.register(SectionBackground.lightBg.self, forDecorationViewOfKind: "folderListBg")
        return layout
    }
}
