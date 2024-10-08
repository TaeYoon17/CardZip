//
//  UINavigationControllerExtensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
extension UINavigationController{
    enum SideType{case left,right}
    func appendView(type: SideType,view: UIView,topInset: CGFloat = 4){
        self.navigationBar.addSubview(view)
        view.snp.makeConstraints { make in

            if self.navigationBar.prefersLargeTitles{
                make.top.equalToSuperview().inset(topInset)
            }else{
                make.centerY.equalToSuperview()
            }
            switch type{
            case .left:
                make.leading.equalToSuperview().inset(16)
            case .right:
                make.trailing.equalToSuperview().inset(16)
            }
        }
    }
    func deleteView(view:UIView){
        self.navigationBar.willRemoveSubview(view)
    }
}
extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
