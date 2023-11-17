//
//  AddSetItemCellVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/26.
//

import Foundation
import Combine

final class AddSetItemCellVM{
    private weak var addSetVM: AddSetVM!
    @Published var cardItem: CardItem
    @Published var isAvailable: Bool = false
    var passthroughDefinitionAction = PassthroughSubject<Void,Never>()
    var passthroughTermAction = PassthroughSubject<Void,Never>()
    var subscription = Set<AnyCancellable>()
    init(addSetVM: AddSetVM!, cardItem: CardItem) {
        self.addSetVM = addSetVM
        self.cardItem = cardItem
        self.$cardItem.sink {cardItem in
            addSetVM.updatedCardItem.send((cardItem,false))
        }.store(in: &subscription)
        if let title = self.addSetVM.setItem?.title{
            self.isAvailable = !title.isEmpty
        }
        addSetVM.updatedSetItem.map{ (item, _ ) in
            item.title.isEmpty
        }.sink {[weak self] titleEmpty in
            self?.isAvailable = !titleEmpty
        }.store(in: &subscription)
    }
    func addImageTapped(){
        addSetVM.cardAction.send((.imageTapped,cardItem))
    }
    func deleteTapped(){
        addSetVM.cardAction.send((.delete, cardItem))
    }
}
