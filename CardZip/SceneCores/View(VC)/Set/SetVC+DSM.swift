//
//  SetVC+DSM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit
extension SetVC{
//    @MainActor func initDataSource(animating: Bool = true){
//        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
//        snapshot.appendSections([.main])
//        guard let items = sectionModel?.fetchByID(.main)?.sumItem else {return}
//        snapshot.appendItems(items, toSection: .main)
//        Task{
//            await dataSource?.apply(snapshot,animatingDifferences: animating)
////            collectionView.reloadData()
//        }
//    }
//    @MainActor func initCheckedDataSource(animagting:Bool = true){
//
//            var snapshot = Snapshot()
//            snapshot.appendSections([.main])
//            guard let items = sectionModel?.fetchByID(.main)?.sumItem.filter ({
//                let card = self.cardModel?.fetchByID($0.id)
//                return card?.isChecked ?? false
//            }) else {return}
//
//            snapshot.appendItems(items,toSection: .main)
//        Task{
//            await dataSource?.apply(snapshot,animatingDifferences: true)
////            collectionView.reloadData()
//        }
//    }
    @MainActor func initDataSource() async throws -> Snapshot{
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        snapshot.appendSections([.main])
        guard let items = sectionModel?.fetchByID(.main)?.sumItem else {
            throw DataSourceError.EmptySnapshot
        }
        snapshot.appendItems(items, toSection: .main)
        return snapshot
//        await dataSource?.apply(snapshot,animatingDifferences: animating)
    }
    @MainActor func initCheckedDataSource() async throws -> Snapshot{
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
            snapshot.appendSections([.main])
            guard let items = sectionModel?.fetchByID(.main)?.sumItem.filter ({
                let card = self.cardModel?.fetchByID($0.id)
                return card?.isChecked ?? false
            }) else { throw DataSourceError.EmptySnapshot }
            snapshot.appendItems(items,toSection: .main)
        return snapshot
//            await dataSource?.apply(snapshot,animatingDifferences: true)
    }
    
    @MainActor func updateCard(item:inout CardItem){
        guard let dbKey = item.dbKey,let cardTable = cardRepository?.getTableBy(tableID: dbKey) else {return}
        if let likedSetId, likedSetId == setItem?.dbKey, !item.isLike{ // 좋아요 세트 테이블인 경우엔 테이블에 없애주어야 한다.
            setRepository?.removeCards(setId: likedSetId, card: cardTable)
        }
        cardRepository?.updateExceptImage(card: cardTable, item: item)
        initModel()
        Task{
            var snapshot:Snapshot
            switch self.vm.studyType{
            case .basic,.random: snapshot = try await initDataSource()
                await dataSource.apply(snapshot,animatingDifferences: false)
            case .check: snapshot = try await initCheckedDataSource()
                await dataSource.apply(snapshot)
            }
            
        }
    }
}
