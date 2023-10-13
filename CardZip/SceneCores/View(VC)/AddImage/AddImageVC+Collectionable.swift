//
//  AddImageVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
import SnapKit
extension AddImageVC: Collectionable{
    func configureCollectionView(){
        collectionView.backgroundColor = .bg
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        let registration = imageRegistration
        let addRegistration = addRegistration
        dataSource = UICollectionViewDiffableDataSource<Section,String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if itemIdentifier == "addBtn"{
                return collectionView.dequeueConfiguredReusableCell(using: addRegistration, for: indexPath, item: itemIdentifier)
            }else{
                let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
                return cell
            }
        })
        Task{
            let imageIds = cardItem?.imageID ?? []
            await selectionUpdate(ids: imageIds)
            updateSnapshot(result: imageIds)
        }
    }
    
    @MainActor func updateSnapshot(result: [String]){
        print(#function, result)
        var snapshot = NSDiffableDataSourceSnapshot<Section,String>()
        snapshot.appendSections([.main])
        self.imageCount = snapshot.itemIdentifiers.count + (result.isEmpty ? 0 : 1)
        snapshot.appendItems(result,toSection: .main)
        snapshot.appendItems(["addBtn"], toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    func selectionUpdate(ids: [String]) async{
        var newSelection:[ String:UIImage] = [:]
        for str in ids{
            newSelection[str] = await .fetchBy(identifier: str)
        }
        self.selection = newSelection
    }
}


extension AddImageVC{
    var layout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self = self else { return }
            let page = round(offset.x / self.view.bounds.width)
            self.imageCount = Int(page)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = .init()
        layout.configuration.scrollDirection = .horizontal
        return layout
    }
}

