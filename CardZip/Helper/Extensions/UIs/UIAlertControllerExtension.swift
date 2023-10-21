//
//  UIAlertControllerExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import UIKit
extension UIAlertController{
    func setAppearance(){
        view.tintColor = .secondaryLabel
        view.backgroundColor = .bg?.withAlphaComponent(0.75)
        view.layer.cornerRadius = 16.5
    }
}
