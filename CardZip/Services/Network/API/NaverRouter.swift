//
//  Router.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/31.
//

import Foundation
import Alamofire
enum NaverRouter{
    typealias Queries = [String:String]
    enum SearchType{
        case image
    }
    enum SortType:String{
        case sim
        case date
    }
    enum FilterType:String{
        case all
        case large
        case medium
        case small
    }
    static let API = "https://openapi.naver.com/v1"
}

