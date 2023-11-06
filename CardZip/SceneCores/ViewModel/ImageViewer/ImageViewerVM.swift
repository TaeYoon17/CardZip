//
//  ImageViewVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import Combine
import RealmSwift
class ImageViewerVM{
    @MainActor lazy var repository = ImageRepository()
    @Published var cardItem: CardItem?
    @Published var setName: String?
    @MainActor final var selection = [String]()
    var imageCount = CurrentValueSubject<Int, Never>(-1)
    var subscription = Set<AnyCancellable>()
    
}
