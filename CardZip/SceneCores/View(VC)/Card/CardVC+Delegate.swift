//
//  CardVC+Delegatr.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import SnapKit
import UIKit
extension CardVC:UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(#function)
        indexPaths.forEach { indexPath in
            guard let cardID = dataSource.itemIdentifier(for: indexPath),let imagePathes = dataSource.cardsModel?.fetchByID(cardID).imageID else {return}
            if let imagePath = imagePathes.first{
                Task{
                    try await ImageService.shared.appendCache(type: .file, name: imagePath)
                    try await ImageService.shared.appendCache(type: .file, name: imagePath,
                                                              size: .init(width: 720, height: 720))
                }
            }
        }
    }
}
