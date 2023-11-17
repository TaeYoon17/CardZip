//
//  ImageSearchVC+Prefetch.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/04.
//

import UIKit
import SnapKit
extension ImageSearchVC:UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let itemID = dataSource.itemIdentifier(for: indexPath), let item = dataSource.fetchItem(id: itemID) else {return}
            Task.detached{
//                try await ImageService.shared.appendCache(link: item.thumbnail,size: .init(width: 360, height: 360))
                try await ImageService.shared.appendCache(type: .search,name: item.thumbnail,size: .init(width: 360, height: 360))
            }
            if vm.imageResults.count - 5 == indexPath.row{
                vm.paginationImage()
            }
        }
    }

}
