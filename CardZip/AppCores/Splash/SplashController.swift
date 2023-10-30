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
    let repository = CardSetRepository()
    let animationView = LottieAnimationView()
    weak var window: UIWindow?
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
        let vc = MainVC()
        let nav = UINavigationController(rootViewController: vc)
        if let recent,let recentTable = repository?.getTableBy(tableID: recent){
            let setItem = SetItem(table: recentTable)
            let setVM = SetVM(setItem: setItem)
            let setVC = SetVC()
            setVC.vm = setVM
            vc.navigationController?.pushViewController(setVC, animated: false)
//            if setItem.cardCount > 0{
//                Task{ setVC.selectAction() }
//            }
        }
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        guard let window else { return }
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.4
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:{[weak self] completed in
            guard let self else {return}
            // MARK: -- 앱 최초 시작시 바로 최근 학습 카드로 넘어가는 로직
        })
    }
    
}
