//
//  CardSetItem.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/10.
//

import Foundation
struct SetItem: Identifiable{
    var id = UUID()
    var title: String = ""
    var setDescription: String = ""
    var imagePath: String?
    var cardList: [CardTable] = []
}
