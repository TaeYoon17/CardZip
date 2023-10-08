//
//  NewCardSetBtn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit

final class NewCardSetBtn: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .cardPrimary
        config.imagePadding = 4
        config.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 16, weight: .bold))
        config.image = .init(systemName: "plus.circle")
        config.attributedTitle = AttributedString("New Card Set" , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
        ]))
        config.imagePadding = 8
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        configuration = config
        setShadowLayer()
    }
    required init?(coder: NSCoder) {
        fatalError("dont use storyboard")
    }
}
