//
//  CardVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import UIKit
import SnapKit
extension CardVC{
    func configureCollectionView(){
        collectionView.backgroundColor = .bg
        collectionView.isScrollEnabled = false
        let cellRegi = cellRegistration
        dataSource = UICollectionViewDiffableDataSource<Section.ID,CardItem.ID>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
        initModeldataSource()
    }
}


extension CardVC:Collectionable{
    var layout: UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        // 하나의 뷰만 보여주기 때문에 가능
        
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self = self else { return }
            let page = round(offset.y / self.view.bounds.height)
            
            self.cardNumber = Int(page)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        return layout
    }
}
