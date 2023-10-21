//
//  CardVC+SND.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/19.
//

import UIKit
import SnapKit
extension CardVC{
    func initDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,CardItem.ID>()
        snapshot.appendSections([.main])
        let subItemIds = self.sectionModel.fetchByID(.main).subItems
        switch studyType {
        case .random: snapshot.appendItems(subItemIds.shuffled(), toSection: .main)
        case .basic,.check: snapshot.appendItems(subItemIds,toSection: .main)
        }
        Task{
            await dataSource.apply(snapshot,animatingDifferences: true)
        }
    }
}
