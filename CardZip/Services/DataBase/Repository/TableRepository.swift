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
    static func getVersion(){
        do{
            
            let config = Realm.Configuration(schemaVersion: 1){ migration, oldSchemaVersion in // 현재 사용하자 사용하는 스키마
                /// 스키마 추가 삭제는 별도의 내용이 추가 될 필요 없음
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: CardTable.className()) { oldObject, newObject in
                        guard let new = newObject else {return}
                        guard let old = oldObject else {return}
                        new["imagePathes"] = "요약하기"
                    }
                }
                //                if oldSchemaVersion < 2 {
                //
                //                }
                //            if oldSchemaVersion < 3 {
                //                migration.renameProperty(onType: DiaryTable.className(), from: "diaryPhoto", to: "photo")
                //            }
                //                if oldSchemaVersion < 4 { }
                //                if oldSchemaVersion < 5{
                //                    // diarySummary 컬럼 추가, title + contents 합쳐서 넣기
                
                //                }
            }
            //            Realm.Configuration.defaultConfiguration = config
        }
    }
}
