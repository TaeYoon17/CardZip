//
//  CardVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import UIKit
import Combine
final class CardCellVM{
    private weak var cardVM: CardVM?
    @Published var isFront: Bool = true
    @Published var cardItem:CardItem
    var showDetailImage = PassthroughSubject<Int,Never>()
    var subscription = Set<AnyCancellable>()
    init(cardVM: CardVM, cardItem: CardItem) {
        self.cardVM = cardVM
        self.cardItem = cardItem
        showDetailImage.sink {value in
            cardVM.passthroughExpandImage.send((cardItem,value))
        }.store(in: &subscription)
        $cardItem.sink {item in
            cardVM.passthroughUpdateCard.send(item)
        }.store(in: &subscription)
    }
    deinit{ print("CardCellVM이 삭제됨!!") }
}
