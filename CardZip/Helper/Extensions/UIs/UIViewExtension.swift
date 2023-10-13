//
//  UIView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit

extension UIView{
    func setShadowLayer(){
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
    }
}
