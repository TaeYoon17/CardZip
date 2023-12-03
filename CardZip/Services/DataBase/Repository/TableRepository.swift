//
//  RealmService.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import RealmSwift

enum RepositoryError: Error{
    case TableNotFound
}

@MainActor class TableRepository<T> where T: Object{
    var realm: Realm!
    private(set) var tasks: Results<T>!
    @MainActor var getTasks:Results<T>{ realm.objects(T.self) }
    init?() {
        realm = try! Realm()
    }
    func checkPath(){
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "경로 없음")
    }
    func checkSchemaVersion(){
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema version: \(version)")
        }catch{
            print(error)
        }
    }
    
    @discardableResult func create(item: T)-> Self?{
        do{
            try realm.write{ realm.add(item) }
            tasks = realm.objects(T.self)
        }catch{
            print("생성 문제")
            return nil
        }
        return self
    }
    func createWithUpdate(item: T){
        do{
            try realm.write{ realm.add(item,update: .modified) }
            tasks = realm.objects(T.self)
        }catch{
            print("생성 문제")
        }
    }
    @discardableResult func delete(item: T)-> Self?{
        do{
            try realm.write{
                realm.delete(item)
                print("삭제 완료")
            }
            tasks = realm.objects(T.self)
        }catch{
            print("삭제 안됨")
            return nil
        }
        return self
    }
    @discardableResult func filter<U:_HasPersistedType>(by: KeyPath<T,U>) -> Self? where U.PersistedType:SortableType{
        tasks = tasks.sorted(by: by)
        return self
    }
    @discardableResult func update<U:_HasPersistedType>(item: T,by: WritableKeyPath<T,U>,data: U) -> Self?{
        var item = item
        do{
            try realm.write{ item[keyPath: by] = data }
        }catch{
            print("값 문제")
            return nil
        }
        return self
    }
    func objectByPrimaryKey<U: ObjectId>(primaryKey: U) -> T? {
        return realm?.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    func getTableBy<U: ObjectId>(tableID: U) -> T?{
        return realm?.object(ofType: T.self, forPrimaryKey: tableID)
    }
    func deleteTableBy<U: ObjectId>(tableID: U?) throws{
        guard let tableID else { throw RepositoryError.TableNotFound }
        guard let obj = realm?.object(ofType: T.self, forPrimaryKey: tableID) else{
            throw RepositoryError.TableNotFound
        }
        delete(item: obj)
        print("Repository 데이터 삭제 완료")
    }
    
}
extension AppDelegate{
    static var nowVersion:UInt64{ 1 }
    func migration(){
        var config = Realm.Configuration(schemaVersion: Self.nowVersion){ migration, oldSchemaVersion in // 현재 사용하자 사용하는 스키마
            /// 스키마 추가 삭제는 별도의 내용이 추가 될 필요 없음
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: CardSetTable.className()) { oldObject, newObject in
                    guard let new = newObject else {return}
                    guard let old = oldObject else {return}
                    print("MigrationGo")
                    guard let albumID = old["imagePath"] as? String? else {
                        fatalError("Error Occured!!")
                    }
                    guard let albumID else {
                        new["imagePath"] = nil
                        return
                    }
                    let albumFileName = albumID.getLocalPathName(type: .photo)
                    App.MigrationHelper.shared.appendImageMigration(fileNames: [albumFileName])
                    new["imagePath"] = albumFileName
//                    print("--------- new cardsettable")
//                    print(new)
                }
                migration.enumerateObjects(ofType: CardTable.className()) { oldObject, newObject in
                    guard let new = newObject else {return}
                    guard let old = oldObject else {return}
//                    let albumDynamicList = old.dynamicList("imagePathes")
                    guard let albumIdList = old["imagePathes"] as? List<String> else {return}
//                    albumIdList.append(objectsIn: albumDynamicList.map{ $0.description })
                    let albumIDs = Array(albumIdList)
                    let albumFileNames = albumIDs.map { $0.getLocalPathName(type: .photo) }
//                    Task{
//                        await self.imageMigration(albumFileNames)
//                    }
                    App.MigrationHelper.shared.appendImageMigration(fileNames: albumFileNames)
                    new["imagePathes"] = albumFileNames
                    print("--------- new setTable")
                    print(new)
                }
            }
        }
        config.schemaVersion = Self.nowVersion
        Realm.Configuration.defaultConfiguration = config
                do {
                    let realm = try Realm()
                    let version = try schemaVersionAtURL(realm.configuration.fileURL!)
                    print("Schema version: \(version)")
                }catch{
                    print(error)
                }
    }
//    private func imageMigration(_ albumFileNames:[String]) async{
//        _ = ImageRC.shared
//        var rcSnapshot = ImageRC.shared.snapshot
//        let saveDocItems = albumFileNames.filter { !rcSnapshot.existItem(id: $0) }
////        print(saveDocItems)
//        await ImageService.shared.saveToDocumentBy(photoIDs: saveDocItems)
//        await albumFileNames.asyncForEach { fileName in
//            await rcSnapshot.plusCount(id: fileName)
//        }
//        ImageRC.shared.apply(rcSnapshot)
//        await ImageRC.shared.saveRepository()
//    }
}
