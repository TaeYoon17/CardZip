//
//  CardSetItem.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/10.
//

import Foundation
import RealmSwift
struct SetItem: Identifiable,Hashable{
    let id = UUID()
    var title: String = ""
    var setDescription: String = ""
    var imagePath: String?
    var dbKey: ObjectId?
    var cardList: [CardItem] = []{
        didSet{ cardCount = cardList.count }
    }
    // cardList에 카드가 없을 수도 있다
    private(set) var cardCount: Int = 0
    
    init(title: String, setDescription: String, imagePath: String? = nil, dbKey: ObjectId? = nil, cardList: [CardItem], cardCount: Int) {
        self.title = title
        self.setDescription = setDescription
        self.imagePath = imagePath
        self.dbKey = dbKey
        self.cardList = cardList
        self.cardCount = cardCount
    }
    init(){}
    init(table: CardSetTable){
        self.title = table.title
        self.setDescription = table.setDescription
        self.imagePath = table.imagePath
        self.dbKey = table._id
        let cardArr = Array(table.cardList).map{CardItem(table: $0)}
        self.cardList = cardArr
        self.cardCount = cardArr.count
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension SetItem{
    @MainActor static func getByTableId(_ objectId: ObjectId?)->SetItem?{
        guard let objectId else {return nil}
        let repository = CardSetRepository()
        repository?.checkPath()
        guard let item = repository?.getTableBy(tableID: objectId) else {return nil}
        return SetItem(table: item)
    }
}
extension SetItem{
    //MARK: -- 세트 삭제 시 세트 헤더 + 카드 셀 이미지들 IRC Minus
    static func removeAllIRC(item: SetItem)async{
        var ircSnapshot = IRC.shared.snapshot
        if let setImageFileName = item.imagePath{
            await ircSnapshot.minusCount(id: setImageFileName)
        }
        let fileNames = item.cardList.flatMap({ $0.imageID })
        await fileNames.asyncForEach{await ircSnapshot.minusCount(id: $0)}
        IRC.shared.apply(ircSnapshot)
        await IRC.shared.saveRepository()
    }
}
