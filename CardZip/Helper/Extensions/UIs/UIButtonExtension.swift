//
//  UIButtonEx.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import Foundation
import UIKit
extension UIButton{
    func setShadowLayer(){
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
    }
}
