//
//  btn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
final class BottomImageBtn: UIButton{
    private override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.imagePadding = 0
        config.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
//        var symbolConfig = UIImage.SymbolConfiguration(textStyle: .headline, scale: .large)
//        var symbolConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14, weight: .heavy))
//        config.image = .init(systemName: "xmark",withConfiguration: symbolConfig)
        config.baseForegroundColor = .cardPrimary
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        self.configuration = config
    }
    convenience init(systemName: String) {
        self.init(frame: .zero)
        let symbolConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14, weight: .heavy))
        self.configuration?.image = .init(systemName: systemName,withConfiguration: symbolConfig)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
