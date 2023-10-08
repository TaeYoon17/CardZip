//
//  AddFolderBtn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit
final class AddFolderBtn: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .cardPrimary
        config.attributedTitle = AttributedString("Add Folder" , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
        ]))
        config.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        configuration = config
        setShadowLayer()
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
