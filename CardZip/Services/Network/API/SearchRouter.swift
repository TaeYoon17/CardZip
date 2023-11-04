//
//  SearchRouter.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/31.
//

import Foundation
import Alamofire
extension NaverRouter{
    enum Search:URLRequestConvertible{
        //        case shopping(query:String,start:Int? = nil,display:Int? = nil,sort:Sort? = nil)
        case image(query:String,display: Int = 72, start: Int = 1, sort:SortType,filter:FilterType)
        var baseURL:URL{ URL(string: NaverRouter.API + "/search")! }
        
        var endPoint:String{
            switch self{
            case .image: return "/image"
            }
        }
        var method: HTTPMethod{
            switch self{
            case .image: return .get
            }
        }
        var header: HTTPHeaders{
            var header = HTTPHeaders()
            header["X-Naver-Client-Id"] = API_Key.id
            header["X-Naver-Client-Secret"] = API_Key.key
            switch self{
            case .image: break
            }
            return header
        }
        var queries:Queries{
            var queries = Queries()
            switch self{
            case let .image(query: query, display: display, start: start, sort: sort, filter: filter):
                queries["query"] = query
                queries["display"] = String(display)
                queries["start"] = String(start)
                queries["sort"] = sort.rawValue
                queries["filter"] = filter.rawValue
            }
            return queries
        }
        func asURLRequest() throws -> URLRequest {
            // queries : [String:String] -> key = value
            let url = baseURL.appendingPathComponent(endPoint)
            guard var urlComponents = URLComponents(url: url,resolvingAgainstBaseURL: true) else {
                return URLRequest(url: url)
            }
            urlComponents.queryItems = queries.map { URLQueryItem(name: $0, value: $1) }
            var request = URLRequest(url: urlComponents.url!)
            request.method = self.method
            request.headers = self.header
            print(request)
            return request
            //            return try .init(url: URL(string: "asdf")!, method: .get)
        }
    }
}
