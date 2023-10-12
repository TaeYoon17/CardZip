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
        config.image = if let navi = self.navigationController{
            .init(systemName: "chevron.left")
        }else{
            .init(systemName: "xmark")
        }
        config.attributedTitle = AttributedString("Set Name" , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]))
        config.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        btn.configuration = config
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 4
        //MARK: -- 여기 엑션 수정
        btn.addAction(.init(handler: { [weak self] _ in
            if let navi = self?.navigationController{
            self?.navigationController?.popViewController(animated: true)
            }else {
                self?.dismiss(animated: true)
            }
        }), for: .touchUpInside)
        return btn
    }
}
