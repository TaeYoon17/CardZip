//
//  ReferenceCountable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation
import RealmSwift
protocol ReferenceCountable:Identifiable{
    var id:String {get}
    var name: String {get set}
    var count: Int {get set}
}
extension ReferenceCountable{
    var id:String{ name }
}
