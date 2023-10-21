//
//  CardVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import Combine
class CardVM{
    @Published var isHeart: Bool = false
    @Published var isChecked: Bool = false
    @Published var isFront: Bool = true
    var showDetailImage = PassthroughSubject<Int,Never>()
    var subscription = Set<AnyCancellable>()
    deinit{ print("CardVM이 삭제됨!!") }
}

