//
//  ImageCollectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
protocol ImageCollectionAble: Collectionable,UIViewController{
    var imageCount:Int {get set}
}
extension ImageCollectionAble{
    var layout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self = self else { return }
            let page = round(offset.x / self.view.bounds.width)
            self.imageCount = Int(page)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        var config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        
        return layout
    }
}
