//
//  SplashController.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/21.
//

import SnapKit
import UIKit
import Lottie
final class SplashController: BaseVC{
    
    @DefaultsState(\.recentSet) var recent
    @DefaultsState(\.likedSet) var liked
    let openType:OpenType
    let repository = CardSetRepository()
    let animationView = LottieAnimationView()
    weak var window: UIWindow?
    init(openType: OpenType = .recent){
        self.openType = openType
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit{
        print("SplachController 삭제")
    }
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(animationView)
    }
    override func configureNavigation() {
        super.configureNavigation()
    }
    override func configureConstraints() {
        super.configureConstraints()
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.33)
        }
    }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        animationView.animation = LottieAnimation.named("Splash")
        animationView.loopMode = .playOnce
        animationView.play {[weak self] completed in
            Task{
                try? await self?.pushVC()
            }
        }
        
    }
    @MainActor func pushVC() async throws{
        App.Manager.shared.updateLikes()
        let vc = MainVC()
        let nav = UINavigationController(rootViewController: vc)
        let setVC = SetVC()
        switch openType {
        case .recent:
            if let recent,let recentTable = repository?.getTableBy(tableID: recent){
                let setItem = SetItem(table: recentTable)
                let setVM = SetVM(setItem: setItem)
                setVC.vm = setVM
                vc.navigationController?.pushViewController(setVC, animated: false)
            }
        case .liked:
            if let liked,let likedTable = repository?.getTableBy(tableID: liked){
                let setItem = SetItem(table: likedTable)
                let setVM = SetVM(setItem: setItem)
                setVC.vm = setVM
                vc.navigationController?.pushViewController(setVC, animated: false)
            }
        }
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        guard let window else { return }
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.4
    }
    
}
