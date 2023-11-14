//
//  CardFrontView+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/25.
//

import UIKit
import SnapKit
extension CardFrontView: UICollectionViewDelegate{
    func configureCollectionView(){
        collectionView.layer.cornerRadius = 16.5
        collectionView.layer.cornerCurve = .circular
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .lightBg
        let cellRegistration = UICollectionView.CellRegistration<ImageCell,Item> {cell, indexPath, itemIdentifier in
            Task{
                cell.image = try await ImageService.shared.fetchByCache(type: .file, name: itemIdentifier.imagePath,size: .init(width: 720, height: 720))
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Section,Item>(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            cell.expandAction = {[weak self] in
                guard let self else {return}
//                print(nowImageIndex)
                if let cardVM{
                    cardVM.showDetailImage.send(nowImageIndex)
                }else{
                    print("cardVM이 없다!!")
                }
            }
            return cell
        })
    }
    var layout: UICollectionViewLayout{
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { [weak self] ( visibleItems, offset, env) in
            guard let indexPath = visibleItems.last?.indexPath else {return}
            guard self?.nowImageIndex != indexPath.row else {return}
            self?.nowImageIndex = indexPath.row
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(#function)
    }

    @MainActor func initDataSource(images:[String]){
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images.map{Item(imagePath: $0)}, toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
}
//extension CardFrontView:UICollectionViewDataSourcePrefetching{
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        indexPaths.forEach { indexPath in
//            guard let itemID = dataSource.itemIdentifier(for: indexPath) else {return}
//            let imagePath = itemID.imagePath
//            Task{
//                try await ImageService.shared.appendEmptyCache(albumID: imagePath,size: .init(width: 720, height: 720))
//            }
//        }
//    }
//}
