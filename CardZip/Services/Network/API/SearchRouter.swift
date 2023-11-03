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
        case image(query:String,display: Int = 40, start: Int = 1, sort:String,filter:String)
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
//        var body: Parameters{
//            let params = Parameters()
//            switch self{
//            case .shopping(query: _): return params
//            }
//        }
//        var queries:Queries{
//            var queries = Queries()
//            switch self{
//            case let .shopping(query: query, start: start, display: display,sort: sort):
//                queries["query"] = query
////                query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                if let display { queries["display"] = String(display)}
//                if let start { queries["start"] = String( (start - 1) * (display ?? 0) + 1) }
//                if let sort{ queries["sort"] = sort.query}
//            }
//            return queries
//        }
//        var headers: Headers{
//            var headers = Headers()
//            switch self{
//            case .shopping:
//                headers["X-Naver-Client-Id"] = ApiKey.Naver.id
//                headers["X-Naver-Client-Secret"] = ApiKey.Naver.secret
//            }
//            return headers
//        }
        
//        var getRequest:URLRequest{
//            // queries : [String:String] -> key = value
//            let url = baseURL.appendingPathComponent(endPoint)
//            guard var urlComponents = URLComponents(url: url,resolvingAgainstBaseURL: true) else {
//                return URLRequest(url: url)
//            }
//            urlComponents.queryItems = queries.map { URLQueryItem(name: $0, value: $1) }
//            var request = URLRequest(url: urlComponents.url!)
//            request.httpMethod = self.method.rawValue
//            headers.forEach{ request.setValue($1, forHTTPHeaderField: $0) }
//            return request
//        }
        func asURLRequest() throws -> URLRequest {
            return try .init(url: URL(string: "asdf")!, method: .get)
        }
    }
}
extension NaverRouter.Search{
    /// - sim: 정확도순으로 내림차순 정렬(기본값)
    /// - date: 날짜순으로 내림차순 정렬
    /// - asc: 가격순으로 오름차순 정렬
    /// - dsc: 가격순으로 내림차순 정렬
    enum Sort:Int,CaseIterable{
        case sim,date,asc,dsc
        var query:String{
            switch self{
            case .asc: return "asc"
            case .date: return "date"
            case .dsc: return "dsc"
            case .sim: return "sim"
            }
        }
        var korean:String{
            switch self{
            case .sim: return "정확도"
            case .dsc: return "가격높은순"
            case .asc: return "가격낮은순"
            case .date: return "날짜순"
            }
        }
    }
}
