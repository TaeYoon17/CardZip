//
//  AppManager.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit
extension App{
    final class Manager{
        static let shared = Manager()
        @DefaultsState(\.likedSet) var liked
        @DefaultsState(\.descriptionLanguageCode) var descriptionLanguageCode
        @DefaultsState(\.termLanguageCode) var termLanguageCode
        private init(){ }
        func gotoPrivacySettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        func hasNotch() -> Bool {
            if #available(iOS 11.0, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                if let topPadding = window?.safeAreaInsets.top, topPadding > 20 {
                    // 노치가 있는 디바이스 (iPhone X 이상)
                    return false
                } else {
                    // 노치가 없는 디바이스 (기존 아이폰 모델)
                    return true
                }
            } else {
                // iOS 11 미만의 버전에서는 노치가 없는 아이폰으로 처리
                return true
            }
        }
        @MainActor func updateLikes(){
            let setRepository = CardSetRepository()
            let cardRepository = setRepository?.cardRespository
            if let liked = self.liked,
               let setTable = setRepository?.getTableBy(tableID: liked),
               let likeCards = cardRepository?.getTasks.where({ query in query.isLike }){
                let repository = CardSetRepository()
                repository?.removeAllCards(id: liked)
                repository?.appendCard(id: liked, cards: Array(likeCards))
                let imageCard = Array(likeCards).first { !$0.imagePathes.isEmpty }
                let image = imageCard?.imagePathes.first
                var setItem = SetItem(table: setTable)
                setItem.imagePath = image
                setItem.title = "Pin Memorize Intensively".localized
                setRepository?.updateHead(set: setTable, setItem: setItem)
            }
        }
        
    }
    final class MigrationHelper{
        static var shared:MigrationHelper? = MigrationHelper()
        private init(){}
        deinit{
            print("사라진다...")
        }
        private var migraionImages:[String] = []
        func appendImageMigration(fileNames:[String]){
            migraionImages.append(contentsOf: fileNames)
        }
        func imageMigration() async {
            // 이미지 참조 목록 생성하기, 마이그레이션 시 아무것도 없어야한다.
            var rcSnapshot = ImageRC.shared.snapshot
            guard rcSnapshot.instance.isEmpty else{
                fatalError("It's not first migration")
            }
            // 위의 이미지 중 중복되지 않게 저장
            await ImageService.shared.saveToDocumentBy(photoIDs: Set(migraionImages).map{$0.extractID(type: .photo)})
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
