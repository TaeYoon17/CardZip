//
//  ImageSearchVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import SnapKit
import UIKit

extension ImageSearchVC:Collectionable{
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        let searchImageCellRegi = searchImageCellRegistration
        dataSource = .init(vm: vm, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: searchImageCellRegi, for: indexPath, item: itemIdentifier)
        })
    }
    
    var layout: UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33)), subitems: [item,item,item] )
        group.interItemSpacing = .fixed(2)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2
//        section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
