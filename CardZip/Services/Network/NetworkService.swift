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
            AF.request(NaverRouter.Search.image(
                query: keyword, display: display, start: start, sort: .sim, filter: .all)
            ).validate(statusCode: (200..<300))
            .publishDecodable(type: ResponseWrapper<ImageSearchResponse>.self,queue: .global())
            .value()
            .sink {[weak self] completion in
                print(completion)
//                continuation.resume(throwing: ResponseError.codeError)
            } receiveValue: {[weak self] response in
                let buildDate = response.lastBuildDate
                do{
                    let encode = try JSONEncoder().encode(response.items)
                    let searchResults = try JSONDecoder().decode([ImageSearch].self, from: encode)
                    print(searchResults)
                    continuation.resume(returning: searchResults)
                }catch{
                    continuation.resume(throwing: error)
                }
            }.store(in: &subscription)
        }
    }
}
