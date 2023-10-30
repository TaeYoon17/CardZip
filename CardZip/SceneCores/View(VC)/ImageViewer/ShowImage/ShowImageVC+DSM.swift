//
//  ShowImageVC+DSM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
extension ShowImageVC{
    @MainActor func updateSnapshot(result: [String]){
        print(#function, result)
        var snapshot = NSDiffableDataSourceSnapshot<Section,String>()
        snapshot.appendSections([.main])
        self.imageCount = snapshot.itemIdentifiers.count + (result.isEmpty ? 0 : 1)
        snapshot.appendItems(result,toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    func selectionUpdate(ids: [String]) async{
        self.selection = ids
    }
}
