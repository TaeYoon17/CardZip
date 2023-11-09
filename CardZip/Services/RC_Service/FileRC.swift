//
//  FileRC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation

protocol ReferenceCounter{
    
}
protocol ReferenceCountable:Identifiable{
    var id:String {get}
    var fileName: String {get set}
    var count: Int {get set}
}
extension ReferenceCountable{
    var id:String{ fileName }
}
class FileRC{
    
}
