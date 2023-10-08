//
//  NavBarButton.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit

class NavBarButton:UIButton{
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(systemName: String) {
        self.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .secondaryLabel
        config.imagePadding = 0
        config.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 14, weight: .heavy))
        config.image = .init(systemName: systemName)
        config.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        self.configuration = config
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard.")
    }
}
