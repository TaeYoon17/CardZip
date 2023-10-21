//
//  SceneDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/04.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    @DefaultsState(\.recentSet) var recent
    @DefaultsState(\.likedSet) var liked
    
    let repository = CardSetRepository()
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        UINavigationBar.appearance().barTintColor = .bg.withAlphaComponent(0.1)
        UINavigationBar.appearance().tintColor = .cardPrimary
        UITextField.appearance().tintColor = .cardPrimary
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let vc = MainVC()
        let nav = UINavigationController(rootViewController: vc)
// MARK: -- 앱 최초 시작시 바로 최근 학습 카드로 넘어가는 로직
        if let recent,let recentTable = repository?.getTableBy(tableID: recent){
            let setItem = SetItem(table: recentTable)
            let setVC = SetVC()
            setVC.setItem = setItem
            vc.navigationController?.pushViewController(setVC, animated: false)
            if setItem.cardCount > 0{
                Task{ setVC.selectAction() }
            }
        }
        
//MARK: -- 앱을 깔고 처음 시작 할 때 코드
        if liked == nil{
            let card = CardSetTable(title: "Pin Memorize Intensively".localized, description: "")
            Task{
                @MainActor in
                let repository = CardSetRepository()
                liked = card._id
                _ = repository?.create(item: card)
            }
        }
        if App.Manager.shared.descriptionLanguageCode == nil{
            App.Manager.shared.descriptionLanguageCode = .ko
        }
        if App.Manager.shared.termLanguageCode == nil{
            App.Manager.shared.termLanguageCode = .ko
        }
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

