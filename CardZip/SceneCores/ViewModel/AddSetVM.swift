//
//  AddSetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import Foundation
import Combine

final class AddSetVM{
    @Published var cards:[CardItem] = []
    func createItem(){ cards.append(.init()) }
}
