//
//  ImageRepository.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

//import Foundation
//import RealmSwift
//import UIKit
//
//@MainActor final class ImageRepository: TableRepository<ImageTable> {
//    
//    func getFileModel(fileName: String) throws ->FileModel{
//        guard let table = realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) else{
//            fatalError("테이블이 없는데 가져오려한다!!")
//        }
//        return FileModel(fileName: table.fileName,count: table.usingCount)
//    }
//    func getAllImageModel()->[FileModel]{
//        getTasks.map { FileModel(fileName: $0.fileName,count: $0.usingCount) }
//    }
//    func update(fileModel: FileModel){
//        let imageTable = if let table = realm?.object(ofType: ImageTable.self, forPrimaryKey: fileModel.fileName){
//            table
//        }else{
//            _createImageTable(fileName: fileModel.fileName)
//        }
//        try! realm.write({
//            imageTable.usingCount = fileModel.count
//        })
//    }
//    enum ClearType{
//        case all
//        case emptyBT
//    }
//    func clearImageTable(type: ClearType = .emptyBT){
//        let allTables = self.getTasks
//        switch type{
//        case .all:
//            try! realm.write{
//                realm.delete(allTables)
//            }
//        case .emptyBT:
//            let emptyTables = allTables.where { $0.usingCount == 0}
//            emptyTables.forEach { tables in
//                FileManager.removeFromDocument(fileName: tables.fileName,type: .jpg)
//            }
//            try! realm.write({
//                realm.delete(emptyTables)
//            })
//        }
//    }
//}
//extension ImageRepository{
//    func plusCntImageTable(fileName: String){
//        guard let imageTable = realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) else{ return }
//        try! realm.write {
//            imageTable.usingCount += 1
//        }
//    }
//    func plusCntImageTables(fileNames: [String]){
//        fileNames.forEach{plusCntImageTable(fileName: $0)}
//    }
//    func minusCntImageTable(fileName: String){
//        guard let imageTable = realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) else{ return }
//        try! realm.write {
//            imageTable.usingCount -= 1
//        }
//    }
//    func minusCntImageTables(fileNames: [String]){
//        fileNames.forEach{minusCntImageTable(fileName: $0)}
//    }
//}
//extension ImageRepository{
//    fileprivate func _createImageTable(fileName: String)->ImageTable{
//        let table = ImageTable(fileName: fileName)
//        self.create(item: table)
//        return table
//    }
//    func createImageTables(fileNames: [String]){
//        fileNames.forEach{createImageTable(fileName: $0)}
//    }
//    func createImageTable(fileName: String){
//        if nil != realm?.object(ofType: ImageTable.self, forPrimaryKey: fileName) { return }
//        _ = _createImageTable(fileName: fileName)
//    }
//}
