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
        collectionView.isScrollEnabled = true
        collectionView.prefetchDataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        
        let cellRegi = cellRegistration
        dataSource = UICollectionViewDiffableDataSource<Section.ID,CardItem.ID>(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            guard let self else {return .init()}
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
            return cell
        })
        initModeldataSource()
    }
}


extension CardVC:Collectionable{
    var layout: UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        // 하나의 뷰만 보여주기 때문에 가능
        
//        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
//            guard let self = self else { return }
//            let page = round((offset.y + 1) / self.view.bounds.height)
//            self.cardNumber = Int(page)
//        }
        section.visibleItemsInvalidationHandler = { [weak self] ( visibleItems, offset, env) in
            guard let indexPath = visibleItems.last?.indexPath else {return}
//            guard self?.nowImageIndex != indexPath.row else {return}
            self?.cardNumber = indexPath.row
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
