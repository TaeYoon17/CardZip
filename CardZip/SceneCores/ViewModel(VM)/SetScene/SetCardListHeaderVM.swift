//
//  SetCardListHeaderVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/27.
//

import Foundation
import Combine
final class SetCardListHeaderVM{
    weak var setVM: SetVM!
    @Published var studyType : StudyType = .basic
    var subscription = Set<AnyCancellable>()
    init(setVM: SetVM!) {
        self.setVM = setVM
        $studyType
            .assign(to: \.studyType,on:setVM)
            .store(in: &subscription)
    }
}
