//
//  UITextField+Combine.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/26.
//

import Foundation
import UIKit
import Combine
extension UITextField{
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
}
