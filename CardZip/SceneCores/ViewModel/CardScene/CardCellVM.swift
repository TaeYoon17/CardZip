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
    weak var cardVM: CardVM?
//    @Published var isHeart: Bool = false
//    @Published var isChecked: Bool = false
    @Published var isFront: Bool = true
    @Published var cardItem:CardItem
    var showDetailImage = PassthroughSubject<Int,Never>()
    var subscription = Set<AnyCancellable>()
    @Published var imagesDict:[String: UIImage?] = [:]
    init(cardVM: CardVM, item: CardItem) {
        self.cardVM = cardVM
        self.cardItem = item
        showDetailImage.sink {[weak self] value in
            guard let self else {return}
            cardVM.passthroughExpandImage.send((item,value))
        }.store(in: &subscription)
        $cardItem.sink { item in
            cardVM.passthroughCardItem.send(item)
        }.store(in: &subscription)
        storeImages(images: item.imageID)
        
    }
    func storeImages(images: [String]){
        Task{
            var newDict:[String: UIImage?] = [:]
            await images.asyncForEach({
                newDict[$0] = await UIImage.fetchBy(identifier: $0,ofSize: .init(width: 360, height: 360))
            })
            self.imagesDict = newDict
        }
    }
    deinit{ print("CardCellVM이 삭제됨!!") }
}
