//
//  CardVC+CustomView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import SnapKit
import UIKit

extension CardVC{
    var CloseBtn:UIButton{
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .secondaryLabel
        config.imagePadding = 4
        config.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 14, weight: .heavy))
         if let navi = self.navigationController{
             config.image = .init(systemName: "chevron.left")
        }else{
            config.image = .init(systemName: "xmark")
        }
        config.attributedTitle = AttributedString("Set Name".prefixString() , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
        ]))
        config.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
        config.cornerStyle = .capsule
        config.titleLineBreakMode = .byTruncatingTail
        
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        btn.configuration = config
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 4
        return btn
    }
    var CountLabel:UIButton{
        let btn = UIButton()
        btn.isUserInteractionEnabled = false
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("\(cardNumber) / \(setItem?.cardCount ?? 0)", attributes: .numberStyle)
        config.baseForegroundColor = .cardPrimary
        config.contentInsets = .init(top: 6, leading: 16, bottom: 6, trailing: 16)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        btn.configuration = config
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 4
        return btn
    }
}
