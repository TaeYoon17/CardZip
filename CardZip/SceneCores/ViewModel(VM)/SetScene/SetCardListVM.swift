//
//  SetCardListVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/27.
//

import UIKit
import SnapKit
import Combine
final class SetCardListVM{
    weak var setVM: SetVM!
    @Published var cardItem: CardItem
    var subscription = Set<AnyCancellable>()
    init(setVM: SetVM!, cardItem: CardItem) {
        self.setVM = setVM
        self.cardItem = cardItem
    }
    func updateCardItem(){
        self.setVM.passthroughUpdateCard.send(cardItem)
    }
}
