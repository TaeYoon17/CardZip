//
//  SetVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
extension SetVC: Collectionable{
    func configureCollectionView(){
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .bg
        let cellRegistration = cardListRegistration
        let cellHeaderRegi = setCardHeaderReusable
        let collectionHeader = setHeaderReusable
        dataSource = DataSource(vm:vm,collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            guard let cardItem = self?.dataSource.cardModel?.fetchByID(itemIdentifier.id), let self else {return .init()}
           return cell
        })
        dataSource.supplementaryViewProvider =  {[weak self]collectionView, kind, indexPath in
            switch kind{
            case "LayoutHeader":
                let view: TopHeaderReusableView =  collectionView.dequeueConfiguredReusableSupplementary(using: collectionHeader, for: indexPath)
                return view
            case UICollectionView.elementKindSectionHeader:
                let view =  collectionView.dequeueConfiguredReusableSupplementary(using: cellHeaderRegi, for: indexPath)
                return view
            default: return nil
            }
        }   
    }
}
extension SetVC{
    var layout:UICollectionViewLayout{
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(128)), subitems: [item])
        group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        let headerSupplement: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(48)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        headerSupplement.pinToVisibleBounds = true
        section.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        section.boundarySupplementaryItems = [headerSupplement]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .fractionalWidth(0.75)),
                                                                        elementKind: "LayoutHeader", alignment: .top)
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        
        layoutConfig.boundarySupplementaryItems = [header]
        layout.configuration = layoutConfig
        return layout
    }
}
