//
//  SetHeaderVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/27.
//

import Foundation
import Combine

final class SetHeaderVM{
    weak var setVM: SetVM!
//    let sectionType:SectionType
    @Published var setItem: SetItem?
    var subscription = Set<AnyCancellable>()
    init(setVM: SetVM!) {
        self.setVM = setVM
        self.setItem = setVM.setItem
    }
    func shuffleAction(){
        setVM.passthroughSuffle.send()
    }
}
