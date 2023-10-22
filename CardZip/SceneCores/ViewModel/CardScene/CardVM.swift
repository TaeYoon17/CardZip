//
//  CardVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/22.
//

import Foundation
import Combine
final class CardVM{
    var passthroughExpandImage = PassthroughSubject<(CardItem,Int),Never>()
    var passthroughCardItem = PassthroughSubject<CardItem,Never>()
    
//    func speakerAction()
//    func tagAction()
}
