//
//  UIImageTransition.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import UIKit
extension UIView{
    static func imageAppear(view:UIView,acting:(()->Void)?){
        UIView.transition(with: view,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: acting, completion: nil)
    }
    //hello
}
