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
        let collectionHeader = setHeaderReusable
        dataSource = UICollectionViewDiffableDataSource<Section.ID,Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
        dataSource.supplementaryViewProvider =  {[weak self]collectionView, kind, indexPath in
            switch kind{
            case "LayoutHeader":
                let view: TopHeaderReusableView =  collectionView.dequeueConfiguredReusableSupplementary(using: collectionHeader, for: indexPath)
                view.shuffleAction = {[weak self] in
                    let vc = CardVC()
                    vc.setItem = self?.setItem
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
                return view
            default: return nil
            }
        }
        
        initModel()
    }
    
}
extension SetVC{
    var layout:UICollectionViewLayout{
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
        group.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
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
