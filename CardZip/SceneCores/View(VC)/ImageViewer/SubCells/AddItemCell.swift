//
//  AddItemCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
import SnapKit

extension AddImageVC{
    final class AddItemCell: BaseCell{
        private lazy var addView = {
            let v = InfoView(title: "Add Image", systemName: "photo.on.rectangle.angled")
            v.action = self.action
            return v
        }()
        var action: (()->Void)?{
            didSet{
                guard let action else {return}
                addView.action = action
            }
        }
        override func configureLayout() {
            super.configureLayout()
            [addView].forEach{contentView.addSubview($0)}
        }
        override func configureConstraints() {
            super.configureConstraints()
            addView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(contentView.safeAreaLayoutGuide).multipliedBy(0.666)
                make.height.equalTo(addView.snp.width)
            }
        }
        override func configureView() {
            super.configureView()
//            addView.setShadowLayer()
//            addView.backgroundColor = .lightBg
//            addView.layer.cornerRadius = 20
//            addView.layer.cornerCurve = .circular
        }
    }
}
