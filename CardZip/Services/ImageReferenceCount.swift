//
//  ImageReferenceCount.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/08.
//

import Foundation
import RealmSwift
struct FileModel:Identifiable{
    var id:String{fileName}
    var fileName: String
    var count: Int = 0
}
//typealias IRC = ImageReferenceCount
//final class ImageReferenceCount{
//    @MainActor private let imageRepository = ImageRepository()!
//    lazy var instance: [FileModel.ID:FileModel] = [:]
//    init(){
//        Task{@MainActor in
//            let models = imageRepository.getAllImageModel()
//            instance = models.reduce(into: [:], { $0[$1.id] = $1 })
//        }
//    }
//    
//    func insertFile(_ model: FileModel){
//        instance[model.id] = model
//    }
//    
//    func plusCount(fileName: String){
//        var model = instance[fileName] ?? FileModel(fileName: fileName,count: 0)
//        model.count += 1
//        instance[fileName] = model
//    }
//    func minusCount(fileName:String) throws{
//        if var fileModel = instance[fileName]{
//            fileModel.count -= 1
//            instance[fileName] = fileModel
//        }else{ fatalError("안된다고")}
//    }
//    
//    func saveToRepository(){
//        Task{@MainActor in
//            instance.forEach { (key, val) in
//                self.imageRepository.update(fileModel: val)
//            }
//            self.imageRepository.clearImageTable(type: .emptyBT)
//        }
//    }
//    @MainActor func fetchByFileName(_ name: String){
//        do{
//            let fileModel:FileModel = try imageRepository.getFileModel(fileName: name)
//            insertFile(fileModel)
//        }catch{
//            print(error)
//        }
//    }
//}
