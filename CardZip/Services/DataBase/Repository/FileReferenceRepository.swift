//
//  FileReferenceRepository.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation
import RealmSwift

@MainActor class ReferenceRepository<T>:TableRepository<T> where T: ReferenceTable{
    func getAllTable()->[ReferenceTable]{
        return getTasks.map { $0 }
    }
    enum ClearType{
        case all
        case emptyBT
    }
    enum FormatType{
        case jpg
    }
    
    func update(item: any ReferenceCountable){
        if let table = realm.object(ofType: T.self, forPrimaryKey: item.name){
            try! realm.write({
                table.count = item.count
            })
        }else{
            let newTable = T.init(fileName: item.name)
            self.create(item: newTable)
            try! realm.write({
                newTable.count = item.count
            })
        }
    }
    
    func clearTable(type: ClearType = .emptyBT,format: FormatType){
        let allTables = self.getTasks
        switch type{
        case .all:
            try! realm.write{
                realm.delete(allTables)
            }
        case .emptyBT:
            let emptyTables = allTables.where { $0.count <= 0 }
            emptyTables.forEach { tables in
                FileManager.removeFromDocument(fileName: tables.name, type: .jpg)
                
            }
            try! realm.write{
                realm.delete(emptyTables)
            }
        }
    }
}
