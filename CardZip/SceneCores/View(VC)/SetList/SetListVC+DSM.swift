//
//  SetListVC+DSM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import UIKit

extension SetListVC{
    func changeItem(before:SetItem.ID,after:SetItem){
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([before])
        setModel.insertModel(item: after)
        snapshot.appendItems([after.id],toSection: .main)
            Task{
                if let imagePath = after.imagePath{
                    self.imageDict[imagePath] = await .fetchBy(identifier: imagePath)?.byPreparingThumbnail(ofSize: .init(width: 66, height: 66))
                }
                await self.dataSource.apply(snapshot,animatingDifferences: true)
        }
    }
}
