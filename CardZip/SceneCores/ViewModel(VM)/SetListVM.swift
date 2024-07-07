//
//  SetListVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import Foundation
import Combine
final class SetListVM{
    @DefaultsState(\.likedSet) var likeKey
    @DefaultsState(\.recentSet) var recentDbKey
    @MainActor lazy var repository = CardSetRepository()
    @Published var isAnimating = true
    @Published var isLoading = true
    @Published var searchText = ""
//     async throws
//    throw RepositoryError.TableNotFound
    @MainActor func getSetItems() async throws -> [SetItem]{
        guard let tasks = self.repository?.getTasks else {throw RepositoryError.TableNotFound }
        let items:[SetItem] = Array(tasks).compactMap {
            if $0._id == self.likeKey { return nil}
            return SetItem(title: $0.title, setDescription: $0.setDescription,
                    imagePath: $0.imagePath, dbKey: $0._id, cardList: [],cardCount: $0.cardList.count)
        }
        return items
    }
    deinit{ print("SetListVM이 사라짐!!") }
}
