//
//  SplashController.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/21.
//

import SnapKit
import UIKit
import Lottie
class SplashController: BaseVC{
    @DefaultsState(\.recentSet) var recent
    @DefaultsState(\.likedSet) var liked
    let repository = CardSetRepository()
    let animationView = LottieAnimationView()
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
            self?.pushVC()
        }
    }
    func pushVC(){
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
        UIApplication.shared.windows.first?.rootViewController = nav
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
