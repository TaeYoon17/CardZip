//
//  SetListVC+DSM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import UIKit

extension SetListVC{
    func changeItem(before:SetItem.ID,after:SetItem?){
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([before])
        var subItems = sectionModel.fetchByID(.main).subItems
        subItems.removeAll { id in id == before }
        sectionModel.insertModel(item: Section(id: .main, subItems: subItems))
        setModel.removeModel(before)
        guard let after else {
            self.dataSource.apply(snapshot,animatingDifferences: true)
            return
        }
        setModel.insertModel(item: after)
        snapshot.appendItems([after.id],toSection: .main)
        Task{
            if let imagePath = after.imagePath{
                self.imageDict[imagePath] = await .fetchBy(identifier: imagePath)?.byPreparingThumbnail(ofSize: .init(width: 66, height: 66))
            }
            await self.dataSource.apply(snapshot,animatingDifferences: true)
        }
    }
    func deleteSetItem(_ id: UUID){
        guard let item:SetItem = setModel.fetchByID(id),let dbKey = item.dbKey else {return}
        var subItems = sectionModel.fetchByID(.main).subItems
        subItems.removeAll(where: { $0 == id })
        setModel.removeModel(id)
        sectionModel.insertModel(item: .init(id: .main, subItems: subItems))
        do{
            repository?.delete(id: dbKey)
            if recentDbKey == dbKey{ recentDbKey = nil }
        }catch{
            print(error)
        }
    }
}
