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
//        guard let cardItem else {return}
//        print(#function,"이게 여러번 울리는 거야",cardItem.title)
        self.setVM.passthroughUpdateCard.send(cardItem)
    }
}
