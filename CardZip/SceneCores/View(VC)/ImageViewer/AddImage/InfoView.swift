//
//  InfoView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import SnapKit
import UIKit

extension AddImageVC{
    final class InfoView: UIView{
        private let addBtn = UIButton()
        private override init(frame: CGRect) { super.init(frame: frame) }
        init(title: String,systemName: String){
            super.init(frame: .zero)
            var config = UIButton.Configuration.plain()
            config.imagePadding = 0
            config.image = .init(systemName: systemName)
            config.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 52))
            config.attributedTitle = .init(title, attributes: .init([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)
            ]))
            config.baseForegroundColor = .cardPrimary
            config.imagePadding = 16
            config.imagePlacement = .top
            addBtn.configuration = config
            addSubview(addBtn)
            addBtn.snp.makeConstraints { $0.edges.equalToSuperview() }
            if let prevAction{ addBtn.removeAction(prevAction, for: .touchUpInside) }
            prevAction = .init(handler: { [weak self] _ in self?.action?() })
            if let prevAction{ addBtn.addAction(prevAction, for: .touchUpInside)}
            setShadowLayer()
            backgroundColor = .lightBg
            layer.cornerRadius = 20
            layer.cornerCurve = .circular
        }
        var prevAction: UIAction?
        var action: (()->Void)?
        required init?(coder: NSCoder) {
            fatalError("이건 아니고")
        }
    }
}
