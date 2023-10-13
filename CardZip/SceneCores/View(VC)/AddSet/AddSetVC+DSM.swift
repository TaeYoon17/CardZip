//
//  AddSetVC+DataManage.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import Foundation
extension AddSetVC{
    @MainActor func reconfigureDataSource(item: Item){
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([item])
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    @MainActor func deleteDataSource(indexPath:IndexPath){
        guard let identifierToDelete = dataSource.itemIdentifier(for: indexPath) else  { return}
        switch vcType{
        case .add: break
        case .edit:
            if let data = self.itemModel.fetchByID(identifierToDelete.id){
                if ((try? repository?.deleteTableBy(tableID: data.dbKey)) != nil) {
                    print("이거 된다!!")
                }else{
                    print("이거 안된다!!")
                }
            }
        }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([identifierToDelete])
        dataSource.apply(snapshot)
    }
}
