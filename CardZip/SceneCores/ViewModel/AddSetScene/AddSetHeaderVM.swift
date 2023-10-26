//
//  AddSetHeaderVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/26.
//

import Foundation
import Combine
final class AddSetHeaderVM{
    private weak var addSetVM: AddSetVM!
    @Published var setItem: SetItem

    var passthroughDefinitionAction = PassthroughSubject<Void,Never>()
    var passthroughTermAction = PassthroughSubject<Void,Never>()
    var subscription = Set<AnyCancellable>()
    init(addSetVM: AddSetVM!, setItem: SetItem) {
        self.addSetVM = addSetVM
        self.setItem = setItem
        
        $setItem.sink {setItem in
            addSetVM.updatedSetItem.send(setItem)
        }.store(in: &subscription)
    }
}
