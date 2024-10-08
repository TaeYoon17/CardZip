//
//  MainVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import Foundation
import Combine

final class MainVM{
    @Published var isExist : Bool = false
    @DefaultsState(\.recentSet) var recentSetTableId
    @DefaultsState(\.likedSet) var likedSetTableId
}
