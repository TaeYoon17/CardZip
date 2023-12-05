//
//  NetworkService.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import Foundation
import Alamofire
import Combine
final class NetworkService{
    enum SearchType{
        case naver
    }
    static let shared = NetworkService()
    var subscription = Set<AnyCancellable>()
    private init(){}
    
    func searchNaverImage(keyword:String,startIndex:Int,display:Int = 42) async throws -> [ImageSearch]{
        let start = (startIndex - 1) * display + 1
        
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {return}
            var flag = true
            let loadingSpinnerTask = Task {
                try await Task.sleep(for: .seconds(5))
                continuation.resume(returning: [])
                return
            }
            AF.request(NaverRouter.Search.image(
                query: keyword, display: display, start: start, sort: .sim, filter: .all)
            ).validate(statusCode: (200..<300))
            .publishDecodable(type: ResponseWrapper<ImageSearchResponse>.self,queue: .global())
            .value()
            .sink {completion in
                if flag{
                    continuation.resume(throwing: ResponseError.codeError)
                    loadingSpinnerTask.cancel()
                    flag.toggle()
                }
            } receiveValue: { response in
                let buildDate = response.lastBuildDate
                do{
                    let encode = try JSONEncoder().encode(response.items)
                    let searchResults = try JSONDecoder().decode([ImageSearch].self, from: encode)
                    if flag{
                        continuation.resume(returning: searchResults)
                        loadingSpinnerTask.cancel()
                        flag.toggle()
                    }
                }catch{
                    if flag{
                        continuation.resume(throwing: error)
                        loadingSpinnerTask.cancel()
                        flag.toggle()
                    }
                }
            }.store(in: &subscription)
        }
    }
}
