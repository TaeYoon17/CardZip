//
//  ErrorPolicy.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import Foundation
enum FetchError:Error{
    case fetch
    case load
    case empty
}
enum SettingError: Error{
    case FailItemable
}
enum DataSourceError: Error{
    case EmptySnapshot
    case SnapshotQueryInvalid
}
