//
//  SetVC+DSM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit
extension SetVC{
    @MainActor func initDataSource(animating: Bool = true){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        snapshot.appendSections([.main])
        guard let items = sectionModel?.fetchByID(.main)?.sumItem else {return}
        snapshot.appendItems(items, toSection: .main)
        Task{
            await dataSource?.apply(snapshot,animatingDifferences: animating)
//            collectionView.reloadData()
        }
    }
    @MainActor func initCheckedDataSource(){
        
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
            snapshot.appendSections([.main])
            guard let items = sectionModel?.fetchByID(.main)?.sumItem.filter ({
                let card = self.cardModel?.fetchByID($0.id)
                return card?.isChecked ?? false
            }) else {return}
            
            snapshot.appendItems(items,toSection: .main)
        Task{
            await dataSource?.apply(snapshot,animatingDifferences: true)
//            collectionView.reloadData()
        }
    }
    @MainActor func updateCard(item:inout CardItem){
        guard let dbKey = item.dbKey,let cardTable = cardRepository?.getTableBy(tableID: dbKey) else {return}
        if let likedSetId, likedSetId == setItem?.dbKey, !item.isLike{ // 좋아요 세트 테이블인 경우엔 테이블에 없애주어야 한다.
            setRepository?.removeCards(setId: likedSetId, card: cardTable)
        }
        cardRepository?.updateExceptImage(card: cardTable, item: item)
        initModel()
        switch self.vm.studyType{
        case .basic,.random: initDataSource(animating: false)
        case .check: initCheckedDataSource()
        }
    }
}
