//
//  ImageSearchVM.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import Foundation
import Combine
import OrderedCollections


final class ImageSearchVM{
    @Published var selectedImage: OrderedDictionary<ImageSearch.ID, ImageSearch>  = [:]
    @Published var imagePathes:[String] = ["getup","googleDrive","picture_demo","rabbit","rabbits"]
    @Published var searchText:String = "asdfsadf"
    @Published private(set) var selectedCount:Int = 0
    var updateItemPassthrough = PassthroughSubject<ImageSearch,ImageSearchError>()
    var limitedCount: Int = 10
    var subscription = Set<AnyCancellable>()
    func toggleCheckItem(_ item:ImageSearch){
        var item = item
        if item.isCheck == false && selectedCount > limitedCount{
            updateItemPassthrough.send(completion: .failure(.overCount))
            return
        }
        item.isCheck.toggle()
        if item.isCheck{
            selectedImage[item.id] = item
            updateItemPassthrough.send(item)
        }else{
            guard let itemIdx = selectedImage.index(forKey: item.id) else {return}
            selectedImage.removeValue(forKey: item.id)
            updateItemPassthrough.send(item)
            for idx in (itemIdx..<selectedImage.count){
                updateItemPassthrough.send(selectedImage.values[idx])
            }
        }
        
        $selectedImage.sink {[weak self] pathes in
            self?.selectedCount = pathes.count
        }.store(in: &subscription)
    }
    
    func getItemCount(_ item:ImageSearch)->Int?{
        selectedImage.keys.firstIndex(of: item.id)
    }
}
extension ImageSearchVM{
    enum ImageSearchError:String,Error{
        case overCount
    }
}
