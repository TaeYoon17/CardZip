//
//  ImageViewVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import Combine
import RealmSwift
import OrderedCollections
import Photos
import PhotosUI
class ImageViewerVM{
    @MainActor final lazy var repository = ImageRepository()
    @Published final var cardItem: CardItem!
    @Published final var setName: String?
    var selectedItems : OrderedSet<String> = []{
        didSet{ selection = Array(selectedItems) }
    }
    @Published private(set) var selection: [ String] = []
    
    var imageCount = CurrentValueSubject<Int, Never>(-1)
    var subscription = Set<AnyCancellable>()
    init(cardItem: CardItem,setName:String){
        self.cardItem = cardItem
        self.setName = setName
        selectedItems.append(contentsOf: cardItem.imageID)
    }
}
