//
//  AppMigrationHelper.swift
//  CardZip
//
//  Created by 김태윤 on 12/4/23.
//

import Foundation
import RealmSwift
extension App{
    final class MigrationHelper{
        static var shared:MigrationHelper? = MigrationHelper()
        private init(){}
        private var migraionImages:[String] = []
        func appendImageMigration(fileNames:[String]){
            migraionImages.append(contentsOf: fileNames)
        }
        private func saveToDocument(){
            Task{
                // 위의 이미지 중 중복되지 않게 저장
                try await ImageService.shared.saveToDocumentBy(photoIDs: Set(migraionImages).map{$0.extractID(type: .photo)})
            }
        }
       @MainActor private func imageMigration() async {
            // 이미지 참조 목록 생성하기, 마이그레이션 시 아무것도 없어야한다.
            var rcSnapshot = ImageRC.shared.snapshot
            guard rcSnapshot.instance.isEmpty else{
                fatalError("It's not first migration")
            }
            // 각각 이미지 참조 개수 증가
            await migraionImages.asyncForEach {
                await rcSnapshot.plusCount(id: $0)
            }
            // 새 참조 개수 적용
            ImageRC.shared.apply(rcSnapshot)
            // DB에 저장
            await ImageRC.shared.saveRepository()
        }
    }
}
extension App.MigrationHelper{
    func migration(){
        var config = Realm.Configuration(schemaVersion: App.dbVersion){[weak self] migration, oldSchemaVersion in // 현재 사용하자 사용하는 스키마
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
                    self?.appendImageMigration(fileNames: [albumFileName])
                    new["imagePath"] = albumFileName
                    
                }
                migration.enumerateObjects(ofType: CardTable.className()) { oldObject, newObject in
                    guard let new = newObject else {return}
                    guard let old = oldObject else {return}
                    guard let albumIdList = old["imagePathes"] as? List<String> else {return}
                    let albumIDs = Array(albumIdList)
                    let albumFileNames = albumIDs.map { $0.getLocalPathName(type: .photo) }
                    self?.appendImageMigration(fileNames: albumFileNames)
                    new["imagePathes"] = albumFileNames
                }
            }
        }
        config.schemaVersion = App.dbVersion
        Realm.Configuration.defaultConfiguration = config
        do {
            let realm = try Realm()
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema version: \(version)")
        }catch{
            print(error)
        }
        saveToDocument()
        // 마이그레이션 할 것이 존재하는 경우
        if !migraionImages.isEmpty{
            DispatchQueue.main.async {
                Task{
                    await self.imageMigration()
                    Task.detached {
                        App.MigrationHelper.shared = nil
                    }
                }
            }
        }
    }
}
