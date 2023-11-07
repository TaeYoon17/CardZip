//
//  ImageRepository.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import RealmSwift
import UIKit

@MainActor final class ImageRepository: TableRepository<ImageTable> {
    // 연결만 해제하기
    func removeBusinessTable(key dbKey:ObjectId,imagePath: String){
        guard let imageTable = realm?.object(ofType: ImageTable.self, forPrimaryKey: imagePath) else{ return }
    }


    func appendBusinessTable(key dbKey: ObjectId,imagePath: String){
        let imageTable = if let table = realm?.object(ofType: ImageTable.self, forPrimaryKey: imagePath){
            table
        }else{
            _createImageTable(imagePath: imagePath)
        }
    }
    func appendBusinessTable(key dbKey: ObjectId,imagePathes: [String]){
        imagePathes.forEach{ appendBusinessTable(key: dbKey, imagePath: $0) }
    }
    enum ClearType{
        case all
        case emptyBT
    }
    func clearImageTable(type: ClearType = .emptyBT){
        let allTables = self.getTasks
        switch type{
        case .all:
            try! realm.write{
                realm.delete(allTables)
            }
        case .emptyBT:
            let emptyTables = allTables.where { $0.usingCount == 0}
            emptyTables.forEach { tables in
                FileManager.removeFromDocument(fileName: tables.imagePath,type: .jpg)
            }
            try! realm.write({
                realm.delete(emptyTables)
            })
        }
    }
}
extension ImageRepository{
    func plusCntImageTable(fileName: String){
        guard let imageTable = realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) else{ return }
        try! realm.write {
            imageTable.usingCount += 1
        }
    }
    func plusCntImageTables(fileNames: [String]){
        fileNames.forEach{plusCntImageTable(fileName: $0)}
    }
    func minusCntImageTable(fileName: String){
        guard let imageTable = realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) else{ return }
        try! realm.write {
            imageTable.usingCount -= 1
        }
    }
    func minusCntImageTables(fileNames: [String]){
        fileNames.forEach{minusCntImageTable(fileName: $0)}
    }
}
extension ImageRepository{
    fileprivate func _createImageTable(imagePath: String)->ImageTable{
        let table = ImageTable(imagePath: imagePath)
        self.create(item: table)
        return table
    }
    func createImageTables(fileNames: [String]){
        fileNames.forEach{createImageTable(fileName: $0)}
    }
    func createImageTable(fileName: String){
        if nil != realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) { return }
        _ = _createImageTable(imagePath: fileName)
    }
}
