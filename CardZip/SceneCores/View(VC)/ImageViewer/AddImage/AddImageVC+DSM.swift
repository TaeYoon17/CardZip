//
//  AddImageVC+DSM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import Foundation
import UIKit
extension AddImageVC{
    @MainActor func updateSnapshot(result: [String]){
        var snapshot = NSDiffableDataSourceSnapshot<Section,String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(result,toSection: .main)
        snapshot.appendItems(["addBtn"], toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    
    @MainActor func getCurrentImageIds()->[String]{
        let snapshot = dataSource.snapshot()
        var items = snapshot.itemIdentifiers(inSection: .main)
        _ = items.popLast()
        return items
    }
    @MainActor func sendImageIDs(){
        /// 1. 스냅샷에서 존재하는 데이터들을 가져온다
        /// 2. 이미지 Identifier리스트를 Passthrough로 던진다.
        let snapshot = self.dataSource.snapshot()
        var items:[String] = snapshot.itemIdentifiers(inSection: .main)
        items.removeLast() // add 버튼 없애기
        self.vm.passthorughImgID.send(((Array(Set(items))),vm.ircSnapShot!))
    }
    @MainActor func deleteCell(item:String){
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        vm.imageCount.value -= 1 // 이게 publish 처럼 작동하는가?
        dataSource.apply(snapshot,animatingDifferences: true)
    }
}
