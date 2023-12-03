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
        static let shared = MigrationHelper()
        private init(){}
        private var migraionImages:[String] = []
        func appendImageMigration(fileNames:[String]){
            migraionImages.append(contentsOf: fileNames)
        }
        @MainActor func imageMigration() async {
//            _ = ImageRC.shared
//            var rcSnapshot = ImageRC.shared.snapshot
//            let saveDocItems = migraionImages.filter { !rcSnapshot.existItem(id: $0) }
            print(migraionImages)
            await ImageService.shared.saveToDocumentBy(photoIDs: migraionImages)
//            await migraionImages.asyncForEach { fileName in
//                await rcSnapshot.plusCount(id: fileName)
//            }
//            ImageRC.shared.apply(rcSnapshot)
//            print(ImageRC.shared.instance)
//            await ImageRC.shared.saveRepository()
        }
    }
}
