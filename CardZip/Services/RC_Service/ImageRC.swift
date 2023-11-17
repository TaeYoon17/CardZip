//
//  FileRC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation
import RealmSwift
struct ImageItem: ReferenceCountable{
    var name: String
    var count: Int
}
typealias IRC = ImageRC
final class ImageRC:ReferenceCounter{
    typealias Item = ImageItem
    typealias Table = ReferenceTable
    @MainActor var repository = ReferenceRepository<ReferenceTable>()!
    static let shared = ImageRC()
    var instance: [Item.ID : ImageItem] = [:]
    private init(){
        Task{ 
            await resetInstance()
            print(instance)
        }
    }
    @MainActor private func resetInstance() async {
        let res = repository.getAllTable().reduce(into: [:]) {
                $0[$1.id] = ImageItem(name: $1.name, count: $1.count)
        }
        self.instance = res
    }
    func plusCount(id: Item.ID) async {
        if instance[id] == nil{
            instance[id] = ImageItem(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    func minusCount(id: Item.ID) async {
        instance[id]?.count -= 1
    }
    
    func insertRepository(item: Item) async{
        await repository.insert(item: item)
    }
    func saveRepository() async {
        await instance.asyncForEach { key,value in
            await self.repository.insert(item: value)
        }
        await repository.clearTable(type: .emptyBT, format: .jpg)
        await resetInstance()
    }
    func apply(_ snapshot: ImageRC.SnapShot){
        instance = snapshot.instance
    }
    var snapshot:SnapShot{ SnapShot(irc: self) }
}


extension ImageRC{
    struct SnapShot{
        typealias Item = ImageItem
        typealias Table = ReferenceTable
        var instance: [Item.ID : ImageItem] = [:]
        init(irc: ImageRC){ 
            instance = irc.instance
            print(instance)
        }
        func existItem(id: Item.ID) -> Bool{
            instance[id] != nil   
        }
        mutating func plusCount(id: Item.ID) async {
            if instance[id] == nil{
                instance[id] = ImageItem(name: id, count: 1)
            }else{
                instance[id]?.count += 1
            }
        }
        mutating func minusCount(id: Item.ID)async {
            instance[id]?.count -= 1
        }
    }
    
}
