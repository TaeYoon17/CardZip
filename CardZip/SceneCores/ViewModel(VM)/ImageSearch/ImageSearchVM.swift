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
    deinit{ print("ImageSearchVM Deinit completed") }
    let limitedCount: Int
    weak var delegate: ImageSearchDelegate?
    @Published private(set) var selectedImage: OrderedDictionary<ImageSearch.ID, ImageSearch>  = [:]
    @Published private(set) var imageResults: [ImageSearch] = []
    @Published private(set) var selectedCount:Int = 0
    var searchText: CurrentValueSubject<String,Never>
    
    var updateItemPassthrough = PassthroughSubject<ImageSearch,Never>()
    var reloadItemsPassthrough = PassthroughSubject<[ImageSearch],Never>()

    var loadingStatusPassthrough = PassthroughSubject<Bool,Never>()
    
    var subscription = Set<AnyCancellable>()
    private var requestNumber = 1
    
    init(searchText: String,imageLimitCount:Int){
        self.searchText = CurrentValueSubject(searchText)
        self.limitedCount = imageLimitCount
        $selectedImage.sink {[weak self] pathes in
            self?.selectedCount = pathes.count
        }.store(in: &subscription)
        self.searchAction()
    }
    private func resetDatas(){
        selectedImage = [:]
        selectedCount = 0
        imageResults = []
        requestNumber = 1
    }
    func saveDatas(){
        // selectedImage에 데이터를 저장하면 된다!!
        delegate?.searchSelectionUpdate(ids: selectedImage.values.map{$0.imagePath})
    }
    
}
//MARK: -- 검색 관련
extension ImageSearchVM{
    func searchAction(){
        resetDatas()
        Task{
            do{
                let images =  try await NetworkService.shared.searchNaverImage(keyword: searchText.value, startIndex: self.requestNumber)
                self.imageResults = images
                self.requestNumber += 1
            }catch{
                print(error)
            }
        }
    }
    func paginationImage(){
        Task{
            do{
                let images = try await NetworkService.shared.searchNaverImage(keyword: self.searchText.value,
                                      startIndex: self.requestNumber)
                self.imageResults.append(contentsOf: images)
                self.requestNumber += 1
            }catch{
                print(error)
                self.requestNumber += 1
            }
        }
        
    }
        
    func toggleCheckItem(_ item:ImageSearch){
        var item = item
        if item.isCheck == false && selectedCount >= limitedCount{
//            updateItemPassthrough.send(completion: .failure(.overCount))
            return
        }
        item.isCheck.toggle()
        if item.isCheck{
            selectedImage[item.id] = item
            updateItemPassthrough.send(item)
        }else{ //false면 지워줘야하지
            guard let itemIdx = selectedImage.index(forKey: item.id) else {return}
            selectedImage.removeValue(forKey: item.id)
            let item = item
            Task.detached(operation: {
                self.updateItemPassthrough.send(item)
                let reloadItems = Array(self.selectedImage.values[itemIdx..<self.selectedImage.count])
                self.reloadItemsPassthrough.send(reloadItems)
            })
        }
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
