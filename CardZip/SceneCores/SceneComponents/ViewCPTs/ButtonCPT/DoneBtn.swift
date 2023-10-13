//
//  DoneBtn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit

final class DoneBtn: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .cardPrimary
        config.attributedTitle = AttributedString("Done" , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
        ]))
        config.contentInsets = .init(top: 6, leading: 14, bottom: 6, trailing: 14)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        configuration = config
        setShadowLayer()
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
