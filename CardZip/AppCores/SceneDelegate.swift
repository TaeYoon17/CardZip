//
//  SceneDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/04.
//

import UIKit
enum OpenType{
    case recent
    case liked
}
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    @DefaultsState(\.recentSet) var recent
    @DefaultsState(\.likedSet) var liked
    let repository = CardSetRepository()
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions")
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        UINavigationBar.appearance().barTintColor = .bg.withAlphaComponent(0.1)
        UINavigationBar.appearance().tintColor = .cardPrimary
        UITextField.appearance().tintColor = .cardPrimary
        
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
//        connectionOptions.urlContexts
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
        //MARK: -- 처음 위젯으로 앱을 열 때 좋아한 탭으로 열기
        let openType:OpenType = if let url = connectionOptions.urlContexts.first?.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true){
            API_Key.intensivelyWidgetKey == urlComponents.path ? OpenType.liked : .recent
        }else {
            .recent
        }
        
        let vc = SplashController(openType: openType)
        vc.window = window
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let intensivelyURL: String = API_Key.intensivelyWidgetKey
        guard let url = URLContexts.first?.url,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        if intensivelyURL == urlComponents.path {
            let vc = SplashController(openType: .liked)
            vc.window = window
            //MARK: -- 메인 뷰 컨트롤러 메모리 삭제 안되는 문제 해결
            if let navi = window?.rootViewController as? UINavigationController, let myVC = navi.viewControllers.first as? MainVC{
                myVC.dataSource = nil
            }
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }
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

